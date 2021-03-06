class Format
  def initialize(time=nil)
    raise ArgumentError unless time.nil? or time.is_a?(Date)
    @time = time
    @ban_list = BanList.new
    @format_sets = format_sets
  end

  def legality(card)
    raise unless card
    return nil if %W[vanguard plane phenomenon scheme token].include?(card.layout)
    if in_format?(card)
      @ban_list.legality(format_name, card.name, @time)
    else
      nil
    end
  end

  def in_format?(card)
    raise unless card
    card.printings.each do |printing|
      next if @time and printing.release_date > @time
      return true if @format_sets.include?(printing.set_code)
    end
    false
  rescue
    binding.pry
  end

  def format_pretty_name
    raise "Subclass responsibility"
  end

  def format_name
    format_pretty_name.downcase
  end

  def format_sets
    raise "SubclassResponsibility"
  end

  def to_s
    if @time
      "<Format:#{format_name}:#{@time}>"
    else
      "<Format:#{format_name}>"
    end
  end

  def inspect
    to_s
  end

  class << self
    def formats_index
      {
        "ia block"                    => FormatIceAgeBlock,
        "ice age block"               => FormatIceAgeBlock,
        "mr block"                    => FormatMirageBlock,
        "mirage block"                => FormatMirageBlock,
        "tp block"                    => FormatTempestBlock,
        "tempest block"               => FormatTempestBlock,
        "us block"                    => FormatUrzaBlock,
        "urza block"                  => FormatUrzaBlock,
        "mm block"                    => FormatMasquesBlock,
        "masques block"               => FormatMasquesBlock,
        "marcadian masques block"     => FormatMasquesBlock,
        "in block"                    => FormatInvasionBlock,
        "invasion block"              => FormatInvasionBlock,
        "od block"                    => FormatOdysseyBlock,
        "odyssey block"               => FormatOdysseyBlock,
        "on block"                    => FormatOnslaughtBlock,
        "onslaught block"             => FormatOnslaughtBlock,
        "mi block"                    => FormatMirrodinBlock,
        "mirrodin block"              => FormatMirrodinBlock,
        "ts block"                    => FormatTimeSpiralBlock,
        "time spiral block"           => FormatTimeSpiralBlock,
        "rav block"                   => FormatRavinicaBlock,
        "ravnica block"               => FormatRavinicaBlock,
        "kamigawa block"              => FormatKamigawaBlock,
        "chk block"                   => FormatKamigawaBlock,
        "champions of kamigawa block" => FormatKamigawaBlock,
        "lw block"                    => FormatLorwynShadowmoorBlock,
        "lorwyn block"                => FormatLorwynShadowmoorBlock,
        "lorwyn-shadowmoor block"     => FormatLorwynShadowmoorBlock,
        "ala block"                   => FormatShardsOfAlaraBlock,
        "alara block"                 => FormatShardsOfAlaraBlock,
        "shards of alara block"       => FormatShardsOfAlaraBlock,
        "zendikar block"              => FormatZendikarBlock,
        "zen block"                   => FormatZendikarBlock,
        "scars of mirrodin block"     => FormatScarsOfMirrodinBlock,
        "som block"                   => FormatScarsOfMirrodinBlock,
        "innistrad block"             => FormatInnistradBlock,
        "isd block"                   => FormatInnistradBlock,
        "return to ravnica block"     => FormatReturnToRavnicaBlock,
        "rtr block"                   => FormatReturnToRavnicaBlock,
        "theros block"                => FormatTherosBlock,
        "ths block"                   => FormatTherosBlock,
        "tarkir block"                => FormatTarkirBlock,
        "ktk block"                   => FormatTarkirBlock,
        "khans of tarkir block"       => FormatTarkirBlock,
        "battle for zendikar block"   => FormatBattleForZendikarBlock,
        "bfz block"                   => FormatBattleForZendikarBlock,
        "soi block"                   => FormatShadowsOverInnistradBlock,
        "shadows over innistrad block"=> FormatShadowsOverInnistradBlock,
        "unsets"                      => FormatUnsets,
        "un-sets"                     => FormatUnsets,
        "standard"                    => FormatStandard,
        "modern"                      => FormatModern,
        "legacy"                      => FormatLegacy,
        "vintage"                     => FormatVintage,
        "commander"                   => FormatCommander,
        "pauper"                      => FormatPauper,
      }
    end

    def [](format)
      formats_index[format] || FormatUnknown
    end

    def all_legalities(card, time=nil)
      result = {}
      formats_index.values.uniq.each do |format_class|
        format = format_class.new(time)
        status = format.legality(card)
        if status
          result[format.format_pretty_name] = status
        end
      end
      result
    end
  end
end

require_relative "format_vintage"
Dir["#{__dir__}/format_*.rb"].each do |path| require_relative path end
