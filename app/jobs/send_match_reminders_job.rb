class SendMatchRemindersJob < ApplicationJob
  queue_as :default

  REMINDER_WINDOW = 3.hours

  def perform
    candidate_matches.find_each do |match|
      pools = pools_covering(match)
      next if pools.empty?
      recipients(match, pools).each do |entry|
        player = entry[:player]
        reminder = MatchReminder.create_or_find_by(player: player, match: match) { |r| r.sent_at = Time.current }
        ReminderMailer.match_reminder(player, match, entry[:pools]).deliver_later if reminder.previously_new_record?
      end
    end
  end

  private

  def candidate_matches
    now = Time.current
    Match.where(status: "scheduled")
         .where("kickoff_at > ? AND kickoff_at <= ?", now, now + REMINDER_WINDOW)
         .where.not(home_team_id: nil).where.not(away_team_id: nil)
  end

  # Pollas del torneo del partido cuya modalidad cubre ese partido.
  def pools_covering(match)
    match.tournament.pools.select { |pool| pool.matches_in_scope.exists?(id: match.id) }
  end

  # Devuelve [{ player:, pools: [...] }] de miembros registrados, con recordatorios activos,
  # sin pronóstico en alguna polla que cubre el partido, y aún no avisados para ese partido.
  def recipients(match, pools)
    pending = {} # player_id => { player:, pools: [] }
    pools.each do |pool|
      predicted_ids = pool.predictions.where(match_id: match.id).pluck(:player_id).to_set
      pool.players.each do |player|
        next unless player.registered? && player.email_reminders
        next if predicted_ids.include?(player.id)
        entry = (pending[player.id] ||= { player: player, pools: [] })
        entry[:pools] << pool
      end
    end
    already = MatchReminder.where(match_id: match.id).pluck(:player_id).to_set
    pending.values.reject { |e| already.include?(e[:player].id) }
  end
end
