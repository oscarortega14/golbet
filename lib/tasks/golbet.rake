namespace :golbet do
  desc "Load World Cup teams + group fixtures (CSV) and build the knockout skeleton"
  task load_fixtures: :environment do
    tournament = Tournament.first_or_create!(name: "Mundial 2026")
    Pool.find_or_create_by!(public: true) { |p| p.tournament = tournament; p.name = "Mundial — General" }
    teams_csv = File.read(Rails.root.join("db/fixtures/teams.csv"))
    matches_csv = File.read(Rails.root.join("db/fixtures/group_matches.csv"))

    result = FixtureImporter.new(tournament, teams_csv: teams_csv, matches_csv: matches_csv).import
    KnockoutBracketBuilder.new(tournament).build

    if result.success?
      puts "OK: #{tournament.teams.count} teams, #{tournament.matches.count} matches " \
           "(#{tournament.matches.where(stage: 'group').count} group + " \
           "#{tournament.matches.where.not(stage: 'group').count} knockout)."
    else
      puts "Importado con #{result.errors.size} error(es):"
      result.errors.each { |e| puts "  - #{e}" }
    end
  end

  desc "Wipe and load a SIMULATED World Cup: groups + R32 + R16 played, quarters onward left to play."
  task demo: :environment do
    raise "No corras golbet:demo en producción." if Rails.env.production?

    # --- Plausible (NOT official) 2026 draw: 48 teams in 12 groups -----------
    DRAW = {
      "A" => [["México", "MEX", "🇲🇽"], ["Croacia", "CRO", "🇭🇷"], ["Arabia Saudita", "SAU", "🇸🇦"], ["Sudáfrica", "RSA", "🇿🇦"]],
      "B" => [["Canadá", "CAN", "🇨🇦"], ["Bélgica", "BEL", "🇧🇪"], ["Corea del Sur", "KOR", "🇰🇷"], ["Egipto", "EGY", "🇪🇬"]],
      "C" => [["Estados Unidos", "USA", "🇺🇸"], ["Países Bajos", "NED", "🇳🇱"], ["Japón", "JPN", "🇯🇵"], ["Ghana", "GHA", "🇬🇭"]],
      "D" => [["Argentina", "ARG", "🇦🇷"], ["Noruega", "NOR", "🇳🇴"], ["Australia", "AUS", "🇦🇺"], ["Costa de Marfil", "CIV", "🇨🇮"]],
      "E" => [["Francia", "FRA", "🇫🇷"], ["Uruguay", "URU", "🇺🇾"], ["Senegal", "SEN", "🇸🇳"], ["Nueva Zelanda", "NZL", "🇳🇿"]],
      "F" => [["Brasil", "BRA", "🇧🇷"], ["Suiza", "SUI", "🇨🇭"], ["Irán", "IRN", "🇮🇷"], ["Panamá", "PAN", "🇵🇦"]],
      "G" => [["España", "ESP", "🇪🇸"], ["Dinamarca", "DEN", "🇩🇰"], ["Marruecos", "MAR", "🇲🇦"], ["Honduras", "HON", "🇭🇳"]],
      "H" => [["Inglaterra", "ENG", "🇬🇧"], ["Serbia", "SRB", "🇷🇸"], ["Túnez", "TUN", "🇹🇳"], ["Jamaica", "JAM", "🇯🇲"]],
      "I" => [["Portugal", "POR", "🇵🇹"], ["Colombia", "COL", "🇨🇴"], ["Camerún", "CMR", "🇨🇲"], ["Catar", "QAT", "🇶🇦"]],
      "J" => [["Alemania", "GER", "🇩🇪"], ["Ecuador", "ECU", "🇪🇨"], ["Nigeria", "NGA", "🇳🇬"], ["Eslovenia", "SVN", "🇸🇮"]],
      "K" => [["Italia", "ITA", "🇮🇹"], ["Perú", "PER", "🇵🇪"], ["Argelia", "ALG", "🇩🇿"], ["Eslovaquia", "SVK", "🇸🇰"]],
      "L" => [["Polonia", "POL", "🇵🇱"], ["Chile", "CHI", "🇨🇱"], ["Paraguay", "PAR", "🇵🇾"], ["Venezuela", "VEN", "🇻🇪"]]
    }.freeze

    ActiveRecord::Base.transaction do
      [Membership, Pool, Prediction, SpecialPrediction, Match, Team, Player, Tournament].each(&:delete_all)
      t = Tournament.create!(name: "Mundial 2026")
      general = Pool.create!(name: "Mundial — General", tournament: t, public: true)

      # Teams
      teams = {}
      DRAW.each do |group, list|
        list.each { |name, code, flag| teams[code] = t.teams.create!(name:, code:, flag:, group:) }
      end

      # Deterministic, varied group score
      score = ->(seed) { [(seed * 7) % 4, (seed * 3) % 3] }

      # Group stage — all played (kickoffs in the past)
      base = 20.days.ago
      pairs = [[0, 1], [2, 3], [0, 2], [1, 3], [3, 0], [1, 2]]
      DRAW.keys.each_with_index do |group, gi|
        codes = DRAW[group].map { |_, code, _| code }
        pairs.each_with_index do |(h, a), pi|
          hs, as_ = score.call(gi * 6 + pi)
          t.matches.create!(stage: "group", group:, home_team: teams[codes[h]], away_team: teams[codes[a]],
                            kickoff_at: base + (gi * 6 + pi).hours, status: "finished", home_score: hs, away_score: as_)
        end
      end

      # Knockout skeleton (32 TBD)
      KnockoutBracketBuilder.new(t).build

      # Qualifiers: top 2 per group (24) + 8 best thirds = 32
      standings = GroupStandingsService.for(t)
      firsts_seconds = standings.values.flat_map { |rows| rows.first(2).map { |r| r[:team] } }
      thirds = standings.values.filter_map { |rows| rows[2] }
      best_thirds = thirds.sort_by { |r| [-r[:pts], -r[:dg], -r[:gf]] }.first(8).map { |r| r[:team] }
      qualifiers = firsts_seconds + best_thirds # 32

      # Helper: assign teams to a round's matches (ordered by slot) and play them (home wins 2-1)
      play_round = lambda do |stage, entrants, when_|
        matches = t.matches.where(stage:).order(:slot).to_a
        matches.each_with_index do |m, i|
          m.update!(home_team: entrants[2 * i], away_team: entrants[2 * i + 1],
                    kickoff_at: when_ + i.hours, status: "finished", home_score: 2, away_score: 1)
        end
        matches.map(&:home_team) # winners
      end

      r32_winners = play_round.call("round_of_32", qualifiers, 10.days.ago)
      r16_winners = play_round.call("round_of_16", r32_winners, 6.days.ago)

      # Quarter-finals: teams assigned, but LEFT TO PLAY (future kickoff) — predict these!
      t.matches.where(stage: "quarter_final").order(:slot).each_with_index do |m, i|
        m.update!(home_team: r16_winners[2 * i], away_team: r16_winners[2 * i + 1],
                  kickoff_at: 2.days.from_now + i.hours, status: "scheduled", home_score: nil, away_score: nil)
      end
      # Semis / 3rd / Final stay TBD (teams unknown) with their future kickoff from the builder.

      # Demo players + predictions on every played match (varied accuracy)
      played = t.matches.where(status: "finished").order(:kickoff_at).to_a
      scorers = ["Mbappé", "Messi", "Haaland", "Kane", "Vinícius", "Lautaro"]
      %w[Ana Beto Caro Diego Eva Oscar].each_with_index do |name, i|
        player = Player.create!(name:)
        Membership.create!(player:, pool: general)
        played.each_with_index do |m, mi|
          exact = i.zero? || ((mi + i) % 3).zero?
          hp = exact ? m.home_score : m.home_score + 1
          ap = exact ? m.away_score : m.away_score
          Prediction.new(player:, pool: general, match: m, home_pred: hp, away_pred: ap).save!(validate: false)
        end
        # special prediction (locked: tournament already started) — seed past the guard
        SpecialPrediction.new(player:, pool: general, champion_team: qualifiers[i], top_scorer: scorers[i]).save!(validate: false)
      end

      # Example PRIVATE pool to showcase the pools UI (registered owner + a couple members)
      owner = Player.create!(name: "Capitán", email: "capi@example.com", email_verified_at: Time.current)
      privada = Pool.create!(name: "Los Cracks", tournament: t, owner: owner,
                             knockout_multipliers: false, champion_bonus: 30)
      [owner, Player.find_by(name: "Ana"), Player.find_by(name: "Beto")].each { |pl| Membership.create!(player: pl, pool: privada) }
      # Tournament left UNRESOLVED (final not played) — resolve it from /admin to award bonuses.
    end

    t = Tournament.first
    general = Pool.general
    puts "✅ Demo cargada: #{Team.count} equipos, #{Match.count} partidos " \
         "(#{Match.where(status: 'finished').count} jugados, #{Match.where(stage: 'quarter_final').count} cuartos por jugar), " \
         "#{Player.count} jugadores demo, #{Prediction.count} pronósticos, #{Pool.count} pollas."
    puts "Líder General: #{ScoringService.standings(general).first&.dig(:player)&.name}"
    puts ""
    puts "Para explorar: bin/dev → entra con tu nombre →"
    puts "  • Grupos: las 12 tablas calculadas de los resultados"
    puts "  • Pronósticos: cuartos de final POR JUGAR (predícelos) + semis/final 'Por definir'"
    puts "  • Ranking: podio con multiplicadores por fase ya aplicados"
    puts "  • Admin (/admin/login): 'Resolver torneo' → define campeón/goleador para ver los bonos"
  end
end
