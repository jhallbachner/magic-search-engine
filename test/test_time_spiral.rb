require_relative "test_helper"

class CardDatabaseTimeSpiralTest < Minitest::Test
  def setup
    @db = load_database("ts", "tsts", "pc", "fut")
  end

  def test_is_future
    assert_search_include "is:future", "Dryad Arbor"
    assert_search_exclude "is:new", "Dryad Arbor"
    assert_search_exclude "is:old", "Dryad Arbor"
    assert_search_results "is:future is:vanilla",
      "Blade of the Sixth Pride",
      "Blind Phantasm",
      "Fomori Nomad",
      "Mass of Ghouls",
      "Nessian Courser",
      "Dryad Arbor" # not sure if it ought to be so
  end

  def test_is_new
    assert_search_exclude "is:future", "Amrou Scout"
    assert_search_include "is:new", "Amrou Scout"
    assert_search_exclude "is:old", "Amrou Scout"
  end

  def test_is_old
    assert_search_exclude "is:future", "Squire"
    assert_search_exclude "is:new", "Squire"
    assert_search_include "is:old", "Squire"
  end

  def test_is_borders
    assert_search_include "is:black-bordered", "Dryad Arbor"
    assert_search_exclude "is:white-bordered", "Dryad Arbor"
    assert_search_exclude "is:silver-bordered", "Dryad Arbor"
  end

  def test_dryad_arbor
    assert_search_include "c:g", "Dryad Arbor"
    assert_search_exclude "c:l", "Dryad Arbor"
    assert_search_exclude "c:c", "Dryad Arbor"
    assert_search_include "is:permanent", "Dryad Arbor"
    assert_search_exclude "is:spell", "Dryad Arbor"
    assert_search_results "t:land t:creature", "Dryad Arbor"
  end

  def test_ghostfire
    assert_search_exclude "c:r", "Ghostfire"
    assert_search_include "ci:r", "Ghostfire"
    assert_search_include "c:c", "Ghostfire"
  end

  def test_non_ascii
    assert_search_results "Dralnu", "Dralnu, Lich Lord"
    assert_search_results "Dralnu Lich Lord", "Dralnu, Lich Lord"
    assert_search_results "Dralnu, Lich Lord", "Dralnu, Lich Lord"
    assert_search_results "Dralnu , Lich Lord", "Dralnu, Lich Lord"
    assert_search_results "Dandân", "Dandan"
    assert_search_results "Dandan", "Dandan"
    assert_search_results "Cutthroat il-Dal", "Cutthroat il-Dal"
    assert_search_results "Cutthroat il Dal", "Cutthroat il-Dal"
    assert_search_results "Cutthroat ildal", "Cutthroat il-Dal" # Thanks to spelling corrections
    assert_search_results "Lim-Dûl the Necromancer", "Lim-Dul the Necromancer"
    assert_search_results "Lim-Dul the Necromancer", "Lim-Dul the Necromancer"
    assert_search_results "Lim Dul the Necromancer", "Lim-Dul the Necromancer"
    assert_search_results "Limdul the Necromancer"
    assert_search_results "limdul necromancer"
    assert_search_results "lim dul necromancer", "Lim-Dul the Necromancer"
    assert_search_results "lim dul necromancer", "Lim-Dul the Necromancer"
    assert_search_results "Sarpadian Empires, Vol. VII", "Sarpadian Empires, Vol. VII"
    assert_search_results "sarpadian empires vol vii", "Sarpadian Empires, Vol. VII"
    assert_search_results "sarpadian empires", "Sarpadian Empires, Vol. VII"
  end

  def test_is_opposes_not
    assert_search_equal "not:future", "-is:future"
    assert_search_equal "not:new", "-is:new"
    assert_search_equal "not:old", "-is:old"
  end

  def test_is_timeshifted
    assert_count_results "is:timeshifted", 45
  end

  def test_manaless_suspend_cards
    assert_search_results "cmc=0 o:suspend", "Ancestral Vision", "Hypergenesis", "Living End", "Lotus Bloom", "Restore Balance", "Wheel of Fate"
    assert_search_results "cmc=0 o:suspend ci:c", "Lotus Bloom"
    assert_search_results "cmc=0 o:suspend ci:u", "Lotus Bloom", "Ancestral Vision"
    assert_search_results "cmc=0 o:suspend c:c", "Lotus Bloom"
    assert_search_results "cmc=0 o:suspend c:u", "Ancestral Vision"
    assert_search_results "cmc=0 o:suspend mana=0"
  end

  # This goes against magiccards.info logic which treats * as 0
  # I'm not sure yet if it makes any sense or not
  def test_lhurgoyfs
    assert_search_results "t:lhurgoyf", "Tarmogoyf", "Detritivore"
    assert_search_results "t:lhurgoyf pow=0"
    assert_search_results "t:lhurgoyf tou=0"
    assert_search_results "t:lhurgoyf tou=1"
    assert_search_results "t:lhurgoyf pow>=0"
    assert_search_results "t:lhurgoyf tou>=0"
    assert_search_results "t:lhurgoyf pow<tou", "Tarmogoyf"
    assert_search_results "t:lhurgoyf pow<=tou", "Tarmogoyf", "Detritivore"
    assert_search_results "t:lhurgoyf pow>=tou", "Detritivore"
    assert_search_results "t:lhurgoyf pow=tou", "Detritivore"
    assert_search_results "t:lhurgoyf pow>tou"
  end

  def test_negative
    assert_search_results "pow=-1", "Char-Rumbler"
    assert_search_results "pow<0", "Char-Rumbler"
    assert_search_include "pow>=-1", "Char-Rumbler"
    assert_search_include "pow>=-2", "Char-Rumbler"
    assert_search_exclude "pow>-1", "Char-Rumbler"
  end
end
