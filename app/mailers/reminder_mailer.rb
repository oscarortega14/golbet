class ReminderMailer < ApplicationMailer
  def match_reminder(player, match, pools)
    @player = player
    @match = match
    @pools = pools
    mail(to: player.email,
         subject: "⏰ No olvides tu pronóstico: #{match.display_home} vs #{match.display_away}")
  end
end
