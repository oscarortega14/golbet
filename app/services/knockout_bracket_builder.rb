class KnockoutBracketBuilder
  # stage => [match count, label prefix, approx kickoff date]
  ROUNDS = {
    "round_of_32"   => [16, "R32",        "2026-06-28 16:00"],
    "round_of_16"   => [8,  "Octavos",    "2026-07-03 16:00"],
    "quarter_final" => [4,  "Cuartos",    "2026-07-09 16:00"],
    "semi_final"    => [2,  "Semis",      "2026-07-14 16:00"],
    "third_place"   => [1,  "3er puesto", "2026-07-18 16:00"],
    "final"         => [1,  "Final",      "2026-07-19 16:00"],
  }.freeze

  def initialize(tournament) = @tournament = tournament

  def build
    ROUNDS.each do |stage, (count, prefix, date)|
      (1..count).each do |slot|
        match = @tournament.matches.find_or_initialize_by(stage: stage, slot: slot)
        next unless match.new_record?
        match.assign_attributes(
          kickoff_at: Time.zone.parse(date),
          home_label: "#{prefix} ##{slot} — Local",
          away_label: "#{prefix} ##{slot} — Visitante"
        )
        match.save!
      end
    end
  end
end
