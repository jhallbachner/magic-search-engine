require_relative "test_helper"

class CardDatabaseRTRTest < Minitest::Test
  def setup
    @db = load_database("rtr", "gtc", "dgm")
  end

  def test_boolean
    assert_search_results "(e:rtr or e:dgm) r:mythic c:w",
      "Blood Baron of Vizkopa",
      "Council of the Absolute",
      "Legion's Initiative",
      "Voice of Resurgence",
      "Angel of Serenity",
      "Armada Wurm",
      "Isperia, Supreme Judge",
      "Sphinx's Revelation",
      "Trostani, Selesnya's Voice"
    assert_search_results "e:gtc t:angel -(c:r tou=3)",
      "Angelic Skirmisher",
      "Aurelia, the Warleader",
      "Guardian of the Gateless",
      "Deathpact Angel"
    assert_search_results "e:gtc t:angel -(c:r or tou=3)",
      "Angelic Skirmisher",
      "Deathpact Angel"
    assert_search_equal "(e:rtr OR e:dgm) t:goblin or t:elf", "((e:rtr OR e:dgm) t:goblin) or t:elf"
    assert_search_differ "(e:rtr OR e:dgm) t:goblin or t:elf", "(e:rtr OR e:dgm) (t:goblin or t:elf)"
    assert_search_equal "t:human t:warrior", "t:human AND t:warrior"
    assert_search_differ "t:human t:warrior", "t:human OR t:warrior"
    assert_search_equal "t:human t:warrior", 't:"human warrior"'
    assert_search_equal "t:human t:warrior", 't:"warrior human"'
    assert_search_equal "t:legendary t:angel", 't:"legendary angel"'
  end

  def test_minus
    assert_search_equal "c!r", "-c:w -c:u -c:b -c:g -c:c -c:l"
    assert_search_equal "c!r", "-(c:w or c:u or c:b or c:g or c:c or c:l)"
    assert_search_equal "t:angel -(r:mythic and c:r)", "t:angel -(r:mythic c:r)"
    assert_search_equal "t:angel -(r:mythic or c:r)", "t:angel -r:mythic -c:r"
  end

  def test_filter_colors_multicolored
    assert_search_include "c:g", "Rubblebelt Raiders"
    assert_search_include "c:r", "Rubblebelt Raiders"
    assert_search_include "c:m", "Rubblebelt Raiders"
    assert_search_include "c:rw", "Rubblebelt Raiders"
    assert_search_include "c:wubrg", "Rubblebelt Raiders"
    assert_search_include "c:wubrgm", "Rubblebelt Raiders"

    assert_search_exclude "c:w", "Rubblebelt Raiders"
    assert_search_exclude "c!g", "Rubblebelt Raiders"
    assert_search_exclude "c!r", "Rubblebelt Raiders"
    assert_search_exclude "c:c", "Rubblebelt Raiders"
    assert_search_exclude "c:l", "Rubblebelt Raiders"
  end

  # It is broken in magiccards.info, fixing so "ci:rg" means "can be played in RG commander deck"
  def test_color_identity
    assert_search_include "ci:rg", "Rubblebelt Raiders"
    assert_search_include "ci:rug", "Rubblebelt Raiders"
    assert_search_exclude "ci:r", "Rubblebelt Raiders"
    assert_search_exclude "ci:c", "Rubblebelt Raiders"
    assert_search_include "ci:gw", "Alive", "Well"
    assert_search_include "ci:rgw", "Alive", "Well"
    assert_search_exclude "ci:rw", "Alive", "Well"
    assert_search_exclude "ci:g", "Alive", "Well"
    assert_search_exclude "ci:w", "Alive", "Well"

    assert_search_include "ci:wubrg", "Boros Cluestone"
    assert_search_include "ci:rw", "Boros Cluestone"
    assert_search_exclude "ci:rg", "Boros Cluestone"
    assert_search_exclude "ci:r", "Boros Cluestone"
    assert_search_exclude "ci:c", "Boros Cluestone"

    assert_search_exclude "ci:c", "Forest"
    assert_search_include "ci:c", "Thespian's Stage"
    assert_search_include "ci:g", "Forest"
    assert_search_exclude "ci:r", "Forest"
  end

  def test_edition
    assert_search_equal "e:rtr", "e:ravnica"
    assert_search_equal "e:rtr", "e:return"
    assert_search_equal "e:rtr", 'e:"Return to Ravnica"'
    assert_search_equal "e:gtc", "e:Gatecrash"
    assert_search_equal "e:dgm", %Q[e:"dragon's maze"]
    assert_search_equal "e:dgm", "e:maze"
  end

  def test_split_cards
    assert_search_exclude "is:split", "Rubblebelt Raiders"
    assert_search_include "is:split", "Alive", "Well"
    assert_search_results "Alive", "Alive"
    assert_search_results "Well", "Well"
    assert_search_results 'o:fuse o:centaur o:"gain 2 life"'
    assert_search_results 'o:fuse o:centaur', "Alive"
    assert_search_results 'o:fuse o:"gain 2 life"', "Well"
    assert_search_equal "o:fuse", "is:split"
    assert_search_equal "is:split", "layout:split"
    assert_search_equal "not:split", "-layout:split"
    assert_search_results "is:flip"
    assert_search_results "is:dfc"
  end

  def test_split_slash_slash_bang
    assert_search_results "!Alive // Well", "Alive", "Well"
    assert_search_results "!Well // Alive", "Alive", "Well"
    assert_search_results "!Alive & Well", "Alive", "Well"
    assert_search_results "!Well & Alive", "Alive", "Well"
    assert_search_results "!Alive//Well", "Alive", "Well"
    assert_search_results "!Well//Alive", "Alive", "Well"
    assert_search_results "!Alive&Well", "Alive", "Well"
    assert_search_results "!Well&Alive", "Alive", "Well"
  end

  def test_split_slash_slash
    assert_search_results "Alive // Well", "Alive", "Well"
    assert_search_results "Well // Alive", "Alive", "Well"
    assert_search_results "Alive & Well", "Alive", "Well"
    assert_search_results "Well & Alive", "Alive", "Well"
    assert_search_results "Alive//Well", "Alive", "Well"
    assert_search_results "Well//Alive", "Alive", "Well"
    assert_search_results "Alive&Well", "Alive", "Well"
    assert_search_results "Well&Alive", "Alive", "Well"
  end

  def test_split_one_side_only
    assert_search_results "Alive //", "Alive", "Well"
    assert_search_results "// Alive", "Alive", "Well"
    assert_search_results "well //", "Alive", "Well"
    assert_search_results "cmc=5 // cmc=2", "Blood", "Flesh"
    assert_search_results "c:r // c:r", "Catch", "Release"
    assert_search_equal "&", "is:split"
  end

  def test_nested_slash_slash
    assert_search_results "(// c:mu) or (c:w // c:u)",
      "Beck", "Call", "Breaking", "Entering", "Catch", "Release",
      "Serve", "Protect"
  end

  def test_is_vanilla
    assert_search_results "e:dgm is:vanilla", "Armored Wolf-Rider", "Bane Alley Blackguard"
  end

  def test_ae
    assert_search_results "Ætherize", "Aetherize"
    assert_search_results "AEtherize", "Aetherize"
    assert_search_results "Aetherize", "Aetherize"
    assert_search_results "ætherize", "Aetherize"
    assert_search_results "aetherize", "Aetherize"
  end

  def test_watermark
    assert_search_include "w:gruul", "Rubblebelt Raiders"
    assert_search_include "w:boros", "Aurelia, the Warleader"
    assert_search_exclude "w:gruul", "Aurelia, the Warleader"
  end

  # {u/g} and {u} don't compare
  def test_mana
    assert_search_results "e:gtc mana=u", "Cloudfin Raptor", "Rapid Hybridization", "Realmwright"
    assert_search_results "e:gtc mana={UG}", "Bioshift"
    assert_search_results "e:gtc mana={u/g}", "Bioshift"
    assert_search_results "e:gtc mana={G/U}", "Bioshift"
    assert_search_results "e:gtc mana={gu}", "Bioshift"
    assert_search_equal "mana={3}{r}{r}", "mana=3rr"
  end

  def test_extort_reminder_text_does_not_affect_ci
    assert_search_results "o:extort ci:w", "Basilica Guards", "Blind Obedience", "Knight of Obligation", "Syndic of Tithes"
    assert_search_results "o:extort ci:b", "Basilica Screecher", "Crypt Ghast", "Pontiff of Blight", "Syndicate Enforcer", "Thrull Parasite"
    assert_search_results "o:extort ci:bw -ci:w -ci:b", "Kingpin's Pet", "Tithe Drinker", "Treasury Thrull", "Vizkopa Confessor"
  end

  def test_other
    assert_search_results "cmc=2 other: cmc=1", "Wear"
    assert_search_results "other:(mana=w)", "Alive", "Wear"
    assert_search_results "other:other:(cmc=1)", "Tear", "Well"
    assert_search_results "c:b other:c:b", "Breaking", "Entering"
    assert_search_results "c:b other:-c:b", "Away", "Down", "Flesh", "Loss", "Toil", "Willing"
  end

  def test_ability_word
    assert_search_include "o:bloodrush", "Ghor-Clan Rampager"
  end

  def test_parentheses
    assert_search_results "(far // away) or t:ral)",
      "Far", "Away", "Ral Zarek"
  end
end
