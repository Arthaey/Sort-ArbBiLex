require 'test/unit'
require 'arb_bi_lex'

class TestArbBiLex < Test::Unit::TestCase
  
  def setup
    $stderr.reopen('/dev/null')
  end

  def assert_abort(&block)
    assert_raise(SystemExit, &block)
  end

  def test_invalid_imports
    assert_abort { ArbBiLex.import(nil, nil) }
    assert_abort { ArbBiLex.import('', '') }
    assert_abort { ArbBiLex.import('foo_sort', nil) }
    assert_abort { ArbBiLex.import('foo_sort', '') }
    assert_abort { ArbBiLex.import('foo_sort', []) }
  end

  def test_invalid_array_specs
    assert_abort { ArbBiLex.import('foo_sort', [[]]) }
    assert_abort { ArbBiLex.import('bar_sort', [['A'], []]) }
    assert_abort { ArbBiLex.import('qux_sort', [['A'], 'B']) }
    assert_abort { ArbBiLex.import('zzz_sort', [['A'], [42]]) }
  end

  def test_very_basic_array_spec
    ArbBiLex.import('foo_sort', [['B'], ['CCC'], ['A']])
    expected = "BB ~ BCCC ~ BA ~ CCC ~ AB ~ AA"
    actual = ArbBiLex.foo_sort("AB", "CCC", "AA", "BB", "BA", "BCCC").join(" ~ ")
    assert_equal(expected, actual)
  end

  def test_basic_array_spec
    ArbBiLex.import('foo_sort', [
      [' '],
      ['A', 'a'],
      ['b'],
      ["h", "x'"],
      ['i'],
      ['u'],
    ])
    expected = "Aba ~ aba ~ ax'ub ~ ahub iki ~ ahuba ~ ahubiki ~ hub ~ x'ub"
    actual = ArbBiLex.foo_sort(
      "ax'ub", 'ahuba', 'ahub iki', 'ahubiki', "x'ub", 'aba', 'Aba', 'hub'
    ).join(' ~ ')
    assert_equal(expected, actual)
  end

  def test_unicode_array_spec
    ArbBiLex.import('foo_sort', [
      [' '],
      ['A', 'a'],
      ['b'],
      ["h", "\u20AC"],
      ['i'],
      ['u'],
    ])
    expected = "Aba ~ aba ~ a\u20ACub ~ ahub iki ~ ahuba ~ ahubiki ~ hub ~ \u20ACub"
    actual = ArbBiLex.foo_sort(
      "a\u20ACub", 'ahuba', 'ahub iki', 'ahubiki', "\u20ACub", 'aba', 'Aba', 'hub'
    ).join(' ~ ')
    assert_equal(expected, actual)
  end

end
