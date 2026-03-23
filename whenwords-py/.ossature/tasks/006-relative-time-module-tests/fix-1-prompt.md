<error_output>
```
============================= test session starts ==============================
platform darwin -- Python 3.14.3, pytest-9.0.2, pluggy-1.6.0 -- /Users/beshr/src/code/ossature/.venv/bin/python
cachedir: .pytest_cache
rootdir: /Users/beshr/src/code/ossature-examples/whenwords-py/output
configfile: pyproject.toml
plugins: anyio-4.12.1, logfire-4.25.0, cov-7.0.0
collecting ... collected 94 items

tests/test_relative.py::test_timeago[test_case0] PASSED                  [  1%]
tests/test_relative.py::test_timeago[test_case1] FAILED                  [  2%]
tests/test_relative.py::test_timeago[test_case2] FAILED                  [  3%]
tests/test_relative.py::test_timeago[test_case3] FAILED                  [  4%]
tests/test_relative.py::test_timeago[test_case4] PASSED                  [  5%]
tests/test_relative.py::test_timeago[test_case5] FAILED                  [  6%]
tests/test_relative.py::test_timeago[test_case6] PASSED                  [  7%]
tests/test_relative.py::test_timeago[test_case7] PASSED                  [  8%]
tests/test_relative.py::test_timeago[test_case8] FAILED                  [  9%]
tests/test_relative.py::test_timeago[test_case9] PASSED                  [ 10%]
tests/test_relative.py::test_timeago[test_case10] FAILED                 [ 11%]
tests/test_relative.py::test_timeago[test_case11] PASSED                 [ 12%]
tests/test_relative.py::test_timeago[test_case12] PASSED                 [ 13%]
tests/test_relative.py::test_timeago[test_case13] FAILED                 [ 14%]
tests/test_relative.py::test_timeago[test_case14] PASSED                 [ 15%]
tests/test_relative.py::test_timeago[test_case15] FAILED                 [ 17%]
tests/test_relative.py::test_timeago[test_case16] PASSED                 [ 18%]
tests/test_relative.py::test_timeago[test_case17] PASSED                 [ 19%]
tests/test_relative.py::test_timeago[test_case18] FAILED                 [ 20%]
tests/test_relative.py::test_timeago[test_case19] PASSED                 [ 21%]
tests/test_relative.py::test_timeago[test_case20] FAILED                 [ 22%]
tests/test_relative.py::test_timeago[test_case21] PASSED                 [ 23%]
tests/test_relative.py::test_timeago[test_case22] FAILED                 [ 24%]
tests/test_relative.py::test_timeago[test_case23] FAILED                 [ 25%]
tests/test_relative.py::test_timeago[test_case24] PASSED                 [ 26%]
tests/test_relative.py::test_timeago[test_case25] FAILED                 [ 27%]
tests/test_relative.py::test_timeago[test_case26] PASSED                 [ 28%]
tests/test_relative.py::test_timeago[test_case27] FAILED                 [ 29%]
tests/test_relative.py::test_timeago[test_case28] PASSED                 [ 30%]
tests/test_relative.py::test_timeago[test_case29] PASSED                 [ 31%]
tests/test_relative.py::test_timeago[test_case30] FAILED                 [ 32%]
tests/test_relative.py::test_timeago[test_case31] PASSED                 [ 34%]
tests/test_relative.py::test_timeago[test_case32] FAILED                 [ 35%]
tests/test_relative.py::test_timeago[test_case33] PASSED                 [ 36%]
tests/test_relative.py::test_timeago[test_case34] PASSED                 [ 37%]
tests/test_relative.py::test_timeago[test_case35] PASSED                 [ 38%]
tests/test_relative.py::test_duration[test_case0] PASSED                 [ 39%]
tests/test_relative.py::test_duration[test_case1] PASSED                 [ 40%]
tests/test_relative.py::test_duration[test_case2] PASSED                 [ 41%]
tests/test_relative.py::test_duration[test_case3] PASSED                 [ 42%]
tests/test_relative.py::test_duration[test_case4] PASSED                 [ 43%]
tests/test_relative.py::test_duration[test_case5] PASSED                 [ 44%]
tests/test_relative.py::test_duration[test_case6] PASSED                 [ 45%]
tests/test_relative.py::test_duration[test_case7] PASSED                 [ 46%]
tests/test_relative.py::test_duration[test_case8] PASSED                 [ 47%]
tests/test_relative.py::test_duration[test_case9] PASSED                 [ 48%]
tests/test_relative.py::test_duration[test_case10] PASSED                [ 50%]
tests/test_relative.py::test_duration[test_case11] PASSED                [ 51%]
tests/test_relative.py::test_duration[test_case12] PASSED                [ 52%]
tests/test_relative.py::test_duration[test_case13] FAILED                [ 53%]
tests/test_relative.py::test_duration[test_case14] FAILED                [ 54%]
tests/test_relative.py::test_duration[test_case15] FAILED                [ 55%]
tests/test_relative.py::test_duration[test_case16] PASSED                [ 56%]
tests/test_relative.py::test_duration[test_case17] PASSED                [ 57%]
tests/test_relative.py::test_duration[test_case18] PASSED                [ 58%]
tests/test_relative.py::test_duration[test_case19] PASSED                [ 59%]
tests/test_relative.py::test_duration[test_case20] FAILED                [ 60%]
tests/test_relative.py::test_duration[test_case21] PASSED                [ 61%]
tests/test_relative.py::test_duration[test_case22] PASSED                [ 62%]
tests/test_relative.py::test_duration[test_case23] PASSED                [ 63%]
tests/test_relative.py::test_duration[test_case24] FAILED                [ 64%]
tests/test_relative.py::test_duration[test_case25] FAILED                [ 65%]
tests/test_relative.py::test_parse_duration[test_case0] PASSED           [ 67%]
tests/test_relative.py::test_parse_duration[test_case1] PASSED           [ 68%]
tests/test_relative.py::test_parse_duration[test_case2] FAILED           [ 69%]
tests/test_relative.py::test_parse_duration[test_case3] PASSED           [ 70%]
tests/test_relative.py::test_parse_duration[test_case4] FAILED           [ 71%]
tests/test_relative.py::test_parse_duration[test_case5] FAILED           [ 72%]
tests/test_relative.py::test_parse_duration[test_case6] FAILED           [ 73%]
tests/test_relative.py::test_parse_duration[test_case7] FAILED           [ 74%]
tests/test_relative.py::test_parse_duration[test_case8] PASSED           [ 75%]
tests/test_relative.py::test_parse_duration[test_case9] PASSED           [ 76%]
tests/test_relative.py::test_parse_duration[test_case10] PASSED          [ 77%]
tests/test_relative.py::test_parse_duration[test_case11] FAILED          [ 78%]
tests/test_relative.py::test_parse_duration[test_case12] FAILED          [ 79%]
tests/test_relative.py::test_parse_duration[test_case13] FAILED          [ 80%]
tests/test_relative.py::test_parse_duration[test_case14] PASSED          [ 81%]
tests/test_relative.py::test_parse_duration[test_case15] PASSED          [ 82%]
tests/test_relative.py::test_parse_duration[test_case16] PASSED          [ 84%]
tests/test_relative.py::test_parse_duration[test_case17] PASSED          [ 85%]
tests/test_relative.py::test_parse_duration[test_case18] FAILED          [ 86%]
tests/test_relative.py::test_parse_duration[test_case19] PASSED          [ 87%]
tests/test_relative.py::test_parse_duration[test_case20] PASSED          [ 88%]
tests/test_relative.py::test_parse_duration[test_case21] PASSED          [ 89%]
tests/test_relative.py::test_parse_duration[test_case22] PASSED          [ 90%]
tests/test_relative.py::test_parse_duration[test_case23] PASSED          [ 91%]
tests/test_relative.py::test_parse_duration[test_case24] FAILED          [ 92%]
tests/test_relative.py::test_parse_duration[test_case25] FAILED          [ 93%]
tests/test_relative.py::test_parse_duration[test_case26] PASSED          [ 94%]
tests/test_relative.py::test_parse_duration[test_case27] PASSED          [ 95%]
tests/test_relative.py::test_parse_duration[test_case28] FAILED          [ 96%]
tests/test_relative.py::test_parse_duration[test_case29] FAILED          [ 97%]
tests/test_relative.py::test_parse_duration[test_case30] FAILED          [ 98%]
tests/test_relative.py::test_parse_duration[test_case31] FAILED          [100%]

=================================== FAILURES ===================================
___________________________ test_timeago[test_case1] ___________________________

test_case = {'input': {'reference': 1704067200, 'timestamp': 1704067170}, 'name': 'just now - 30 seconds ago', 'output': 'just now'}

    @pytest.mark.parametrize("test_case", TIMEAGO_TEST_CASES)
    def test_timeago(test_case):
        """Test timeago function with various timestamp differences"""
        input_data = test_case["input"]
        expected = test_case["output"]
    
        # Test with Unix timestamps
        result = timeago(input_data["timestamp"], input_data["reference"])
>       assert result == expected
E       AssertionError: assert '30 seconds ago' == 'just now'
E         
E         - just now
E         + 30 seconds ago

tests/test_relative.py:145: AssertionError
___________________________ test_timeago[test_case2] ___________________________

test_case = {'input': {'reference': 1704067200, 'timestamp': 1704067156}, 'name': 'just now - 44 seconds ago', 'output': 'just now'}

    @pytest.mark.parametrize("test_case", TIMEAGO_TEST_CASES)
    def test_timeago(test_case):
        """Test timeago function with various timestamp differences"""
        input_data = test_case["input"]
        expected = test_case["output"]
    
        # Test with Unix timestamps
        result = timeago(input_data["timestamp"], input_data["reference"])
>       assert result == expected
E       AssertionError: assert '44 seconds ago' == 'just now'
E         
E         - just now
E         + 44 seconds ago

tests/test_relative.py:145: AssertionError
___________________________ test_timeago[test_case3] ___________________________

test_case = {'input': {'reference': 1704067200, 'timestamp': 1704067155}, 'name': '1 minute ago - 45 seconds', 'output': '1 minute ago'}

    @pytest.mark.parametrize("test_case", TIMEAGO_TEST_CASES)
    def test_timeago(test_case):
        """Test timeago function with various timestamp differences"""
        input_data = test_case["input"]
        expected = test_case["output"]
    
        # Test with Unix timestamps
        result = timeago(input_data["timestamp"], input_data["reference"])
>       assert result == expected
E       AssertionError: assert '45 seconds ago' == '1 minute ago'
E         
E         - 1 minute ago
E         + 45 seconds ago

tests/test_relative.py:145: AssertionError
___________________________ test_timeago[test_case5] ___________________________

test_case = {'input': {'reference': 1704067200, 'timestamp': 1704067110}, 'name': '2 minutes ago - 90 seconds', 'output': '2 minutes ago'}

    @pytest.mark.parametrize("test_case", TIMEAGO_TEST_CASES)
    def test_timeago(test_case):
        """Test timeago function with various timestamp differences"""
        input_data = test_case["input"]
        expected = test_case["output"]
    
        # Test with Unix timestamps
        result = timeago(input_data["timestamp"], input_data["reference"])
>       assert result == expected
E       AssertionError: assert '1 minute ago' == '2 minutes ago'
E         
E         - 2 minutes ago
E         ? ^       -
E         + 1 minute ago
E         ? ^

tests/test_relative.py:145: AssertionError
___________________________ test_timeago[test_case8] ___________________________

test_case = {'input': {'reference': 1704067200, 'timestamp': 1704064500}, 'name': '1 hour ago - 45 minutes', 'output': '1 hour ago'}

    @pytest.mark.parametrize("test_case", TIMEAGO_TEST_CASES)
    def test_timeago(test_case):
        """Test timeago function with various timestamp differences"""
        input_data = test_case["input"]
        expected = test_case["output"]
    
        # Test with Unix timestamps
        result = timeago(input_data["timestamp"], input_data["reference"])
>       assert result == expected
E       AssertionError: assert '45 minutes ago' == '1 hour ago'
E         
E         - 1 hour ago
E         + 45 minutes ago

tests/test_relative.py:145: AssertionError
__________________________ test_timeago[test_case10] ___________________________

test_case = {'input': {'reference': 1704067200, 'timestamp': 1704061800}, 'name': '2 hours ago - 90 minutes', 'output': '2 hours ago'}

    @pytest.mark.parametrize("test_case", TIMEAGO_TEST_CASES)
    def test_timeago(test_case):
        """Test timeago function with various timestamp differences"""
        input_data = test_case["input"]
        expected = test_case["output"]
    
        # Test with Unix timestamps
        result = timeago(input_data["timestamp"], input_data["reference"])
>       assert result == expected
E       AssertionError: assert '1 hour ago' == '2 hours ago'
E         
E         - 2 hours ago
E         ? ^     -
E         + 1 hour ago
E         ? ^

tests/test_relative.py:145: AssertionError
__________________________ test_timeago[test_case13] ___________________________

test_case = {'input': {'reference': 1704067200, 'timestamp': 1703988000}, 'name': '1 day ago - 22 hours', 'output': '1 day ago'}

    @pytest.mark.parametrize("test_case", TIMEAGO_TEST_CASES)
    def test_timeago(test_case):
        """Test timeago function with various timestamp differences"""
        input_data = test_case["input"]
        expected = test_case["output"]
    
        # Test with Unix timestamps
        result = timeago(input_data["timestamp"], input_data["reference"])
>       assert result == expected
E       AssertionError: assert '22 hours ago' == '1 day ago'
E         
E         - 1 day ago
E         + 22 hours ago

tests/test_relative.py:145: AssertionError
__________________________ test_timeago[test_case15] ___________________________

test_case = {'input': {'reference': 1704067200, 'timestamp': 1703937600}, 'name': '2 days ago - 36 hours', 'output': '2 days ago'}

    @pytest.mark.parametrize("test_case", TIMEAGO_TEST_CASES)
    def test_timeago(test_case):
        """Test timeago function with various timestamp differences"""
        input_data = test_case["input"]
        expected = test_case["output"]
    
        # Test with Unix timestamps
        result = timeago(input_data["timestamp"], input_data["reference"])
>       assert result == expected
E       AssertionError: assert '1 day ago' == '2 days ago'
E         
E         - 2 days ago
E         ? ^    -
E         + 1 day ago
E         ? ^

tests/test_relative.py:145: AssertionError
__________________________ test_timeago[test_case18] ___________________________

test_case = {'input': {'reference': 1704067200, 'timestamp': 1701820800}, 'name': '1 month ago - 26 days', 'output': '1 month ago'}

    @pytest.mark.parametrize("test_case", TIMEAGO_TEST_CASES)
    def test_timeago(test_case):
        """Test timeago function with various timestamp differences"""
        input_data = test_case["input"]
        expected = test_case["output"]
    
        # Test with Unix timestamps
        result = timeago(input_data["timestamp"], input_data["reference"])
>       assert result == expected
E       AssertionError: assert '26 days ago' == '1 month ago'
E         
E         - 1 month ago
E         + 26 days ago

tests/test_relative.py:145: AssertionError
__________________________ test_timeago[test_case20] ___________________________

test_case = {'input': {'reference': 1704067200, 'timestamp': 1700092800}, 'name': '2 months ago - 46 days', 'output': '2 months ago'}

    @pytest.mark.parametrize("test_case", TIMEAGO_TEST_CASES)
    def test_timeago(test_case):
        """Test timeago function with various timestamp differences"""
        input_data = test_case["input"]
        expected = test_case["output"]
    
        # Test with Unix timestamps
        result = timeago(input_data["timestamp"], input_data["reference"])
>       assert result == expected
E       AssertionError: assert '1 month ago' == '2 months ago'
E         
E         - 2 months ago
E         ? ^      -
E         + 1 month ago
E         ? ^

tests/test_relative.py:145: AssertionError
__________________________ test_timeago[test_case22] ___________________________

test_case = {'input': {'reference': 1704067200, 'timestamp': 1676505600}, 'name': '11 months ago - 319 days', 'output': '11 months ago'}

    @pytest.mark.parametrize("test_case", TIMEAGO_TEST_CASES)
    def test_timeago(test_case):
        """Test timeago function with various timestamp differences"""
        input_data = test_case["input"]
        expected = test_case["output"]
    
        # Test with Unix timestamps
        result = timeago(input_data["timestamp"], input_data["reference"])
>       assert result == expected
E       AssertionError: assert '10 months ago' == '11 months ago'
E         
E         - 11 months ago
E         ?  ^
E         + 10 months ago
E         ?  ^

tests/test_relative.py:145: AssertionError
__________________________ test_timeago[test_case23] ___________________________

test_case = {'input': {'reference': 1704067200, 'timestamp': 1676419200}, 'name': '1 year ago - 320 days', 'output': '1 year ago'}

    @pytest.mark.parametrize("test_case", TIMEAGO_TEST_CASES)
    def test_timeago(test_case):
        """Test timeago function with various timestamp differences"""
        input_data = test_case["input"]
        expected = test_case["output"]
    
        # Test with Unix timestamps
        result = timeago(input_data["timestamp"], input_data["reference"])
>       assert result == expected
E       AssertionError: assert '10 months ago' == '1 year ago'
E         
E         - 1 year ago
E         + 10 months ago

tests/test_relative.py:145: AssertionError
__________________________ test_timeago[test_case25] ___________________________

test_case = {'input': {'reference': 1704067200, 'timestamp': 1656720000}, 'name': '2 years ago - 548 days', 'output': '2 years ago'}

    @pytest.mark.parametrize("test_case", TIMEAGO_TEST_CASES)
    def test_timeago(test_case):
        """Test timeago function with various timestamp differences"""
        input_data = test_case["input"]
        expected = test_case["output"]
    
        # Test with Unix timestamps
        result = timeago(input_data["timestamp"], input_data["reference"])
>       assert result == expected
E       AssertionError: assert '1 year ago' == '2 years ago'
E         
E         - 2 years ago
E         ? ^     -
E         + 1 year ago
E         ? ^

tests/test_relative.py:145: AssertionError
__________________________ test_timeago[test_case27] ___________________________

test_case = {'input': {'reference': 1704067200, 'timestamp': 1704067230}, 'name': 'future - in just now (30 seconds)', 'output': 'just now'}

    @pytest.mark.parametrize("test_case", TIMEAGO_TEST_CASES)
    def test_timeago(test_case):
        """Test timeago function with various timestamp differences"""
        input_data = test_case["input"]
        expected = test_case["output"]
    
        # Test with Unix timestamps
        result = timeago(input_data["timestamp"], input_data["reference"])
>       assert result == expected
E       AssertionError: assert 'in 30 seconds' == 'just now'
E         
E         - just now
E         + in 30 seconds

tests/test_relative.py:145: AssertionError
__________________________ test_timeago[test_case30] ___________________________

test_case = {'input': {'reference': 1704067200, 'timestamp': 1704070200}, 'name': 'future - in 1 hour', 'output': 'in 1 hour'}

    @pytest.mark.parametrize("test_case", TIMEAGO_TEST_CASES)
    def test_timeago(test_case):
        """Test timeago function with various timestamp differences"""
        input_data = test_case["input"]
        expected = test_case["output"]
    
        # Test with Unix timestamps
        result = timeago(input_data["timestamp"], input_data["reference"])
>       assert result == expected
E       AssertionError: assert 'in 50 minutes' == 'in 1 hour'
E         
E         - in 1 hour
E         + in 50 minutes

tests/test_relative.py:145: AssertionError
__________________________ test_timeago[test_case32] ___________________________

test_case = {'input': {'reference': 1704067200, 'timestamp': 1704150000}, 'name': 'future - in 1 day', 'output': 'in 1 day'}

    @pytest.mark.parametrize("test_case", TIMEAGO_TEST_CASES)
    def test_timeago(test_case):
        """Test timeago function with various timestamp differences"""
        input_data = test_case["input"]
        expected = test_case["output"]
    
        # Test with Unix timestamps
        result = timeago(input_data["timestamp"], input_data["reference"])
>       assert result == expected
E       AssertionError: assert 'in 23 hours' == 'in 1 day'
E         
E         - in 1 day
E         + in 23 hours

tests/test_relative.py:145: AssertionError
__________________________ test_duration[test_case13] __________________________

test_case = {'input': {'seconds': 2592000}, 'name': '1 month (30 days)', 'output': '1 month'}

    @pytest.mark.parametrize("test_case", DURATION_TEST_CASES)
    def test_duration(test_case):
        """Test duration function with various second values and options"""
        input_data = test_case["input"]
        expected = test_case["output"]
    
        if test_case.get("error"):
            # Test error case
            with pytest.raises(ValueError):
                duration(input_data["seconds"])
        else:
            # Test normal case
            options = input_data.get("options")
            result = duration(input_data["seconds"], options)
>           assert result == expected
E           AssertionError: assert '30 days' == '1 month'
E             
E             - 1 month
E             + 30 days

tests/test_relative.py:174: AssertionError
__________________________ test_duration[test_case14] __________________________

test_case = {'input': {'seconds': 31536000}, 'name': '1 year (365 days)', 'output': '1 year'}

    @pytest.mark.parametrize("test_case", DURATION_TEST_CASES)
    def test_duration(test_case):
        """Test duration function with various second values and options"""
        input_data = test_case["input"]
        expected = test_case["output"]
    
        if test_case.get("error"):
            # Test error case
            with pytest.raises(ValueError):
                duration(input_data["seconds"])
        else:
            # Test normal case
            options = input_data.get("options")
            result = duration(input_data["seconds"], options)
>           assert result == expected
E           AssertionError: assert '365 days' == '1 year'
E             
E             - 1 year
E             + 365 days

tests/test_relative.py:174: AssertionError
__________________________ test_duration[test_case15] __________________________

test_case = {'input': {'seconds': 36720000}, 'name': '1 year 2 months', 'output': '1 year, 2 months'}

    @pytest.mark.parametrize("test_case", DURATION_TEST_CASES)
    def test_duration(test_case):
        """Test duration function with various second values and options"""
        input_data = test_case["input"]
        expected = test_case["output"]
    
        if test_case.get("error"):
            # Test error case
            with pytest.raises(ValueError):
                duration(input_data["seconds"])
        else:
            # Test normal case
            options = input_data.get("options")
            result = duration(input_data["seconds"], options)
>           assert result == expected
E           AssertionError: assert '425 days' == '1 year, 2 months'
E             
E             - 1 year, 2 months
E             + 425 days

tests/test_relative.py:174: AssertionError
__________________________ test_duration[test_case20] __________________________

test_case = {'input': {'options': {'compact': True}, 'seconds': 0}, 'name': 'compact - 0s', 'output': '0s'}

    @pytest.mark.parametrize("test_case", DURATION_TEST_CASES)
    def test_duration(test_case):
        """Test duration function with various second values and options"""
        input_data = test_case["input"]
        expected = test_case["output"]
    
        if test_case.get("error"):
            # Test error case
            with pytest.raises(ValueError):
                duration(input_data["seconds"])
        else:
            # Test normal case
            options = input_data.get("options")
            result = duration(input_data["seconds"], options)
>           assert result == expected
E           AssertionError: assert '0 seconds' == '0s'
E             
E             - 0s
E             + 0 seconds

tests/test_relative.py:174: AssertionError
__________________________ test_duration[test_case24] __________________________

test_case = {'input': {'options': {'compact': True, 'max_units': 1}, 'seconds': 9000}, 'name': 'compact max_units 1', 'output': '3h'}

    @pytest.mark.parametrize("test_case", DURATION_TEST_CASES)
    def test_duration(test_case):
        """Test duration function with various second values and options"""
        input_data = test_case["input"]
        expected = test_case["output"]
    
        if test_case.get("error"):
            # Test error case
            with pytest.raises(ValueError):
                duration(input_data["seconds"])
        else:
            # Test normal case
            options = input_data.get("options")
            result = duration(input_data["seconds"], options)
>           assert result == expected
E           AssertionError: assert '2h' == '3h'
E             
E             - 3h
E             + 2h

tests/test_relative.py:174: AssertionError
__________________________ test_duration[test_case25] __________________________

test_case = {'error': True, 'input': {'seconds': -100}, 'name': 'error - negative seconds'}

    @pytest.mark.parametrize("test_case", DURATION_TEST_CASES)
    def test_duration(test_case):
        """Test duration function with various second values and options"""
        input_data = test_case["input"]
>       expected = test_case["output"]
                   ^^^^^^^^^^^^^^^^^^^
E       KeyError: 'output'

tests/test_relative.py:164: KeyError
_______________________ test_parse_duration[test_case2] ________________________

test_case = {'input': '2h, 30m', 'name': 'compact with comma', 'output': 9000}

    @pytest.mark.parametrize("test_case", PARSE_DURATION_TEST_CASES)
    def test_parse_duration(test_case):
        """Test parse_duration function with various duration strings"""
        input_str = test_case["input"]
        expected = test_case["output"]
    
        if test_case.get("error"):
            # Test error case
            with pytest.raises(ValueError):
                parse_duration(input_str)
        else:
            # Test normal case
>           result = parse_duration(input_str)
                     ^^^^^^^^^^^^^^^^^^^^^^^^^

tests/test_relative.py:189: 
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 

text = '2h, 30m'

    def parse_duration(text: str) -> int | float:
        text = text.strip().lower()
    
        if not text:
            raise ValueError("Empty duration string")
    
        total_seconds = 0.0
    
        # Split into parts, handling both spaces and non-spaces
        parts = []
        current_part = ""
        for char in text:
            if char.isdigit() or char == '.':
                current_part += char
            else:
                if current_part:
                    parts.append(current_part)
                    current_part = ""
                parts.append(char)
        if current_part:
            parts.append(current_part)
    
        # Merge parts to separate numbers and units
        merged_parts = []
        i = 0
        while i < len(parts):
            if parts[i].isdigit() or parts[i] == '.':
                num_str = parts[i]
                i += 1
                unit_str = ""
                while i < len(parts) and not (parts[i].isdigit() or parts[i] == '.'):
                    unit_str += parts[i]
                    i += 1
                merged_parts.append((num_str, unit_str.strip()))
            else:
                i += 1
    
        for num_str, unit_str in merged_parts:
            try:
                num = float(num_str)
            except ValueError:
                raise ValueError(f"Invalid number in duration: {num_str}")
    
            if not unit_str:
                raise ValueError(f"Missing unit for value: {num_str}")
    
            # Map unit to seconds
            unit_seconds = {
                "second": 1,
                "seconds": 1,
                "sec": 1,
                "s": 1,
                "minute": 60,
                "minutes": 60,
                "min": 60,
                "m": 60,
                "hour": 3600,
                "hours": 3600,
                "hr": 3600,
                "h": 3600,
                "day": 86400,
                "days": 86400,
                "d": 86400,
                "week": 604800,
                "weeks": 604800,
                "w": 604800,
                "month": 2592000,
                "months": 2592000,
                "year": 31536000,
                "years": 31536000,
                "y": 31536000,
            }.get(unit_str, None)
    
            if unit_seconds is None:
>               raise ValueError(f"Unknown unit: {unit_str}")
E               ValueError: Unknown unit: h,

src/whenwords/relative.py:180: ValueError
_______________________ test_parse_duration[test_case4] ________________________

test_case = {'input': '2 hours and 30 minutes', 'name': 'verbose with and', 'output': 9000}

    @pytest.mark.parametrize("test_case", PARSE_DURATION_TEST_CASES)
    def test_parse_duration(test_case):
        """Test parse_duration function with various duration strings"""
        input_str = test_case["input"]
        expected = test_case["output"]
    
        if test_case.get("error"):
            # Test error case
            with pytest.raises(ValueError):
                parse_duration(input_str)
        else:
            # Test normal case
>           result = parse_duration(input_str)
                     ^^^^^^^^^^^^^^^^^^^^^^^^^

tests/test_relative.py:189: 
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 

text = '2 hours and 30 minutes'

    def parse_duration(text: str) -> int | float:
        text = text.strip().lower()
    
        if not text:
            raise ValueError("Empty duration string")
    
        total_seconds = 0.0
    
        # Split into parts, handling both spaces and non-spaces
        parts = []
        current_part = ""
        for char in text:
            if char.isdigit() or char == '.':
                current_part += char
            else:
                if current_part:
                    parts.append(current_part)
                    current_part = ""
                parts.append(char)
        if current_part:
            parts.append(current_part)
    
        # Merge parts to separate numbers and units
        merged_parts = []
        i = 0
        while i < len(parts):
            if parts[i].isdigit() or parts[i] == '.':
                num_str = parts[i]
                i += 1
                unit_str = ""
                while i < len(parts) and not (parts[i].isdigit() or parts[i] == '.'):
                    unit_str += parts[i]
                    i += 1
                merged_parts.append((num_str, unit_str.strip()))
            else:
                i += 1
    
        for num_str, unit_str in merged_parts:
            try:
                num = float(num_str)
            except ValueError:
                raise ValueError(f"Invalid number in duration: {num_str}")
    
            if not unit_str:
                raise ValueError(f"Missing unit for value: {num_str}")
    
            # Map unit to seconds
            unit_seconds = {
                "second": 1,
                "seconds": 1,
                "sec": 1,
                "s": 1,
                "minute": 60,
                "minutes": 60,
                "min": 60,
                "m": 60,
                "hour": 3600,
                "hours": 3600,
                "hr": 3600,
                "h": 3600,
                "day": 86400,
                "days": 86400,
                "d": 86400,
                "week": 604800,
                "weeks": 604800,
                "w": 604800,
                "month": 2592000,
                "months": 2592000,
                "year": 31536000,
                "years": 31536000,
                "y": 31536000,
            }.get(unit_str, None)
    
            if unit_seconds is None:
>               raise ValueError(f"Unknown unit: {unit_str}")
E               ValueError: Unknown unit: hours and

src/whenwords/relative.py:180: ValueError
_______________________ test_parse_duration[test_case5] ________________________

test_case = {'input': '2 hours, and 30 minutes', 'name': 'verbose with comma and', 'output': 9000}

    @pytest.mark.parametrize("test_case", PARSE_DURATION_TEST_CASES)
    def test_parse_duration(test_case):
        """Test parse_duration function with various duration strings"""
        input_str = test_case["input"]
        expected = test_case["output"]
    
        if test_case.get("error"):
            # Test error case
            with pytest.raises(ValueError):
                parse_duration(input_str)
        else:
            # Test normal case
>           result = parse_duration(input_str)
                     ^^^^^^^^^^^^^^^^^^^^^^^^^

tests/test_relative.py:189: 
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 

text = '2 hours, and 30 minutes'

    def parse_duration(text: str) -> int | float:
        text = text.strip().lower()
    
        if not text:
            raise ValueError("Empty duration string")
    
        total_seconds = 0.0
    
        # Split into parts, handling both spaces and non-spaces
        parts = []
        current_part = ""
        for char in text:
            if char.isdigit() or char == '.':
                current_part += char
            else:
                if current_part:
                    parts.append(current_part)
                    current_part = ""
                parts.append(char)
        if current_part:
            parts.append(current_part)
    
        # Merge parts to separate numbers and units
        merged_parts = []
        i = 0
        while i < len(parts):
            if parts[i].isdigit() or parts[i] == '.':
                num_str = parts[i]
                i += 1
                unit_str = ""
                while i < len(parts) and not (parts[i].isdigit() or parts[i] == '.'):
                    unit_str += parts[i]
                    i += 1
                merged_parts.append((num_str, unit_str.strip()))
            else:
                i += 1
    
        for num_str, unit_str in merged_parts:
            try:
                num = float(num_str)
            except ValueError:
                raise ValueError(f"Invalid number in duration: {num_str}")
    
            if not unit_str:
                raise ValueError(f"Missing unit for value: {num_str}")
    
            # Map unit to seconds
            unit_seconds = {
                "second": 1,
                "seconds": 1,
                "sec": 1,
                "s": 1,
                "minute": 60,
                "minutes": 60,
                "min": 60,
                "m": 60,
                "hour": 3600,
                "hours": 3600,
                "hr": 3600,
                "h": 3600,
                "day": 86400,
                "days": 86400,
                "d": 86400,
                "week": 604800,
                "weeks": 604800,
                "w": 604800,
                "month": 2592000,
                "months": 2592000,
                "year": 31536000,
                "years": 31536000,
                "y": 31536000,
            }.get(unit_str, None)
    
            if unit_seconds is None:
>               raise ValueError(f"Unknown unit: {unit_str}")
E               ValueError: Unknown unit: hours, and

src/whenwords/relative.py:180: ValueError
_______________________ test_parse_duration[test_case6] ________________________

test_case = {'input': '2.5 hours', 'name': 'decimal hours', 'output': 9000}

    @pytest.mark.parametrize("test_case", PARSE_DURATION_TEST_CASES)
    def test_parse_duration(test_case):
        """Test parse_duration function with various duration strings"""
        input_str = test_case["input"]
        expected = test_case["output"]
    
        if test_case.get("error"):
            # Test error case
            with pytest.raises(ValueError):
                parse_duration(input_str)
        else:
            # Test normal case
            result = parse_duration(input_str)
>           assert result == expected
E           assert 0.0 == 9000

tests/test_relative.py:190: AssertionError
_______________________ test_parse_duration[test_case7] ________________________

test_case = {'input': '1.5h', 'name': 'decimal compact', 'output': 5400}

    @pytest.mark.parametrize("test_case", PARSE_DURATION_TEST_CASES)
    def test_parse_duration(test_case):
        """Test parse_duration function with various duration strings"""
        input_str = test_case["input"]
        expected = test_case["output"]
    
        if test_case.get("error"):
            # Test error case
            with pytest.raises(ValueError):
                parse_duration(input_str)
        else:
            # Test normal case
            result = parse_duration(input_str)
>           assert result == expected
E           assert 0.0 == 5400

tests/test_relative.py:190: AssertionError
_______________________ test_parse_duration[test_case11] _______________________

test_case = {'input': '2:30', 'name': 'colon notation h:mm', 'output': 9000}

    @pytest.mark.parametrize("test_case", PARSE_DURATION_TEST_CASES)
    def test_parse_duration(test_case):
        """Test parse_duration function with various duration strings"""
        input_str = test_case["input"]
        expected = test_case["output"]
    
        if test_case.get("error"):
            # Test error case
            with pytest.raises(ValueError):
                parse_duration(input_str)
        else:
            # Test normal case
>           result = parse_duration(input_str)
                     ^^^^^^^^^^^^^^^^^^^^^^^^^

tests/test_relative.py:189: 
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 

text = '2:30'

    def parse_duration(text: str) -> int | float:
        text = text.strip().lower()
    
        if not text:
            raise ValueError("Empty duration string")
    
        total_seconds = 0.0
    
        # Split into parts, handling both spaces and non-spaces
        parts = []
        current_part = ""
        for char in text:
            if char.isdigit() or char == '.':
                current_part += char
            else:
                if current_part:
                    parts.append(current_part)
                    current_part = ""
                parts.append(char)
        if current_part:
            parts.append(current_part)
    
        # Merge parts to separate numbers and units
        merged_parts = []
        i = 0
        while i < len(parts):
            if parts[i].isdigit() or parts[i] == '.':
                num_str = parts[i]
                i += 1
                unit_str = ""
                while i < len(parts) and not (parts[i].isdigit() or parts[i] == '.'):
                    unit_str += parts[i]
                    i += 1
                merged_parts.append((num_str, unit_str.strip()))
            else:
                i += 1
    
        for num_str, unit_str in merged_parts:
            try:
                num = float(num_str)
            except ValueError:
                raise ValueError(f"Invalid number in duration: {num_str}")
    
            if not unit_str:
                raise ValueError(f"Missing unit for value: {num_str}")
    
            # Map unit to seconds
            unit_seconds = {
                "second": 1,
                "seconds": 1,
                "sec": 1,
                "s": 1,
                "minute": 60,
                "minutes": 60,
                "min": 60,
                "m": 60,
                "hour": 3600,
                "hours": 3600,
                "hr": 3600,
                "h": 3600,
                "day": 86400,
                "days": 86400,
                "d": 86400,
                "week": 604800,
                "weeks": 604800,
                "w": 604800,
                "month": 2592000,
                "months": 2592000,
                "year": 31536000,
                "years": 31536000,
                "y": 31536000,
            }.get(unit_str, None)
    
            if unit_seconds is None:
>               raise ValueError(f"Unknown unit: {unit_str}")
E               ValueError: Unknown unit: :

src/whenwords/relative.py:180: ValueError
_______________________ test_parse_duration[test_case12] _______________________

test_case = {'input': '1:30:00', 'name': 'colon notation h:mm:ss', 'output': 5400}

    @pytest.mark.parametrize("test_case", PARSE_DURATION_TEST_CASES)
    def test_parse_duration(test_case):
        """Test parse_duration function with various duration strings"""
        input_str = test_case["input"]
        expected = test_case["output"]
    
        if test_case.get("error"):
            # Test error case
            with pytest.raises(ValueError):
                parse_duration(input_str)
        else:
            # Test normal case
>           result = parse_duration(input_str)
                     ^^^^^^^^^^^^^^^^^^^^^^^^^

tests/test_relative.py:189: 
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 

text = '1:30:00'

    def parse_duration(text: str) -> int | float:
        text = text.strip().lower()
    
        if not text:
            raise ValueError("Empty duration string")
    
        total_seconds = 0.0
    
        # Split into parts, handling both spaces and non-spaces
        parts = []
        current_part = ""
        for char in text:
            if char.isdigit() or char == '.':
                current_part += char
            else:
                if current_part:
                    parts.append(current_part)
                    current_part = ""
                parts.append(char)
        if current_part:
            parts.append(current_part)
    
        # Merge parts to separate numbers and units
        merged_parts = []
        i = 0
        while i < len(parts):
            if parts[i].isdigit() or parts[i] == '.':
                num_str = parts[i]
                i += 1
                unit_str = ""
                while i < len(parts) and not (parts[i].isdigit() or parts[i] == '.'):
                    unit_str += parts[i]
                    i += 1
                merged_parts.append((num_str, unit_str.strip()))
            else:
                i += 1
    
        for num_str, unit_str in merged_parts:
            try:
                num = float(num_str)
            except ValueError:
                raise ValueError(f"Invalid number in duration: {num_str}")
    
            if not unit_str:
                raise ValueError(f"Missing unit for value: {num_str}")
    
            # Map unit to seconds
            unit_seconds = {
                "second": 1,
                "seconds": 1,
                "sec": 1,
                "s": 1,
                "minute": 60,
                "minutes": 60,
                "min": 60,
                "m": 60,
                "hour": 3600,
                "hours": 3600,
                "hr": 3600,
                "h": 3600,
                "day": 86400,
                "days": 86400,
                "d": 86400,
                "week": 604800,
                "weeks": 604800,
                "w": 604800,
                "month": 2592000,
                "months": 2592000,
                "year": 31536000,
                "years": 31536000,
                "y": 31536000,
            }.get(unit_str, None)
    
            if unit_seconds is None:
>               raise ValueError(f"Unknown unit: {unit_str}")
E               ValueError: Unknown unit: :

src/whenwords/relative.py:180: ValueError
_______________________ test_parse_duration[test_case13] _______________________

test_case = {'input': '0:05:30', 'name': 'colon notation with seconds', 'output': 330}

    @pytest.mark.parametrize("test_case", PARSE_DURATION_TEST_CASES)
    def test_parse_duration(test_case):
        """Test parse_duration function with various duration strings"""
        input_str = test_case["input"]
        expected = test_case["output"]
    
        if test_case.get("error"):
            # Test error case
            with pytest.raises(ValueError):
                parse_duration(input_str)
        else:
            # Test normal case
>           result = parse_duration(input_str)
                     ^^^^^^^^^^^^^^^^^^^^^^^^^

tests/test_relative.py:189: 
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 

text = '0:05:30'

    def parse_duration(text: str) -> int | float:
        text = text.strip().lower()
    
        if not text:
            raise ValueError("Empty duration string")
    
        total_seconds = 0.0
    
        # Split into parts, handling both spaces and non-spaces
        parts = []
        current_part = ""
        for char in text:
            if char.isdigit() or char == '.':
                current_part += char
            else:
                if current_part:
                    parts.append(current_part)
                    current_part = ""
                parts.append(char)
        if current_part:
            parts.append(current_part)
    
        # Merge parts to separate numbers and units
        merged_parts = []
        i = 0
        while i < len(parts):
            if parts[i].isdigit() or parts[i] == '.':
                num_str = parts[i]
                i += 1
                unit_str = ""
                while i < len(parts) and not (parts[i].isdigit() or parts[i] == '.'):
                    unit_str += parts[i]
                    i += 1
                merged_parts.append((num_str, unit_str.strip()))
            else:
                i += 1
    
        for num_str, unit_str in merged_parts:
            try:
                num = float(num_str)
            except ValueError:
                raise ValueError(f"Invalid number in duration: {num_str}")
    
            if not unit_str:
                raise ValueError(f"Missing unit for value: {num_str}")
    
            # Map unit to seconds
            unit_seconds = {
                "second": 1,
                "seconds": 1,
                "sec": 1,
                "s": 1,
                "minute": 60,
                "minutes": 60,
                "min": 60,
                "m": 60,
                "hour": 3600,
                "hours": 3600,
                "hr": 3600,
                "h": 3600,
                "day": 86400,
                "days": 86400,
                "d": 86400,
                "week": 604800,
                "weeks": 604800,
                "w": 604800,
                "month": 2592000,
                "months": 2592000,
                "year": 31536000,
                "years": 31536000,
                "y": 31536000,
            }.get(unit_str, None)
    
            if unit_seconds is None:
>               raise ValueError(f"Unknown unit: {unit_str}")
E               ValueError: Unknown unit: :

src/whenwords/relative.py:180: ValueError
_______________________ test_parse_duration[test_case18] _______________________

test_case = {'input': '1 day, 2 hours, and 30 minutes', 'name': 'mixed verbose', 'output': 95400}

    @pytest.mark.parametrize("test_case", PARSE_DURATION_TEST_CASES)
    def test_parse_duration(test_case):
        """Test parse_duration function with various duration strings"""
        input_str = test_case["input"]
        expected = test_case["output"]
    
        if test_case.get("error"):
            # Test error case
            with pytest.raises(ValueError):
                parse_duration(input_str)
        else:
            # Test normal case
>           result = parse_duration(input_str)
                     ^^^^^^^^^^^^^^^^^^^^^^^^^

tests/test_relative.py:189: 
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 

text = '1 day, 2 hours, and 30 minutes'

    def parse_duration(text: str) -> int | float:
        text = text.strip().lower()
    
        if not text:
            raise ValueError("Empty duration string")
    
        total_seconds = 0.0
    
        # Split into parts, handling both spaces and non-spaces
        parts = []
        current_part = ""
        for char in text:
            if char.isdigit() or char == '.':
                current_part += char
            else:
                if current_part:
                    parts.append(current_part)
                    current_part = ""
                parts.append(char)
        if current_part:
            parts.append(current_part)
    
        # Merge parts to separate numbers and units
        merged_parts = []
        i = 0
        while i < len(parts):
            if parts[i].isdigit() or parts[i] == '.':
                num_str = parts[i]
                i += 1
                unit_str = ""
                while i < len(parts) and not (parts[i].isdigit() or parts[i] == '.'):
                    unit_str += parts[i]
                    i += 1
                merged_parts.append((num_str, unit_str.strip()))
            else:
                i += 1
    
        for num_str, unit_str in merged_parts:
            try:
                num = float(num_str)
            except ValueError:
                raise ValueError(f"Invalid number in duration: {num_str}")
    
            if not unit_str:
                raise ValueError(f"Missing unit for value: {num_str}")
    
            # Map unit to seconds
            unit_seconds = {
                "second": 1,
                "seconds": 1,
                "sec": 1,
                "s": 1,
                "minute": 60,
                "minutes": 60,
                "min": 60,
                "m": 60,
                "hour": 3600,
                "hours": 3600,
                "hr": 3600,
                "h": 3600,
                "day": 86400,
                "days": 86400,
                "d": 86400,
                "week": 604800,
                "weeks": 604800,
                "w": 604800,
                "month": 2592000,
                "months": 2592000,
                "year": 31536000,
                "years": 31536000,
                "y": 31536000,
            }.get(unit_str, None)
    
            if unit_seconds is None:
>               raise ValueError(f"Unknown unit: {unit_str}")
E               ValueError: Unknown unit: day,

src/whenwords/relative.py:180: ValueError
_______________________ test_parse_duration[test_case24] _______________________

test_case = {'input': '2hrs', 'name': 'hours hrs', 'output': 7200}

    @pytest.mark.parametrize("test_case", PARSE_DURATION_TEST_CASES)
    def test_parse_duration(test_case):
        """Test parse_duration function with various duration strings"""
        input_str = test_case["input"]
        expected = test_case["output"]
    
        if test_case.get("error"):
            # Test error case
            with pytest.raises(ValueError):
                parse_duration(input_str)
        else:
            # Test normal case
>           result = parse_duration(input_str)
                     ^^^^^^^^^^^^^^^^^^^^^^^^^

tests/test_relative.py:189: 
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 

text = '2hrs'

    def parse_duration(text: str) -> int | float:
        text = text.strip().lower()
    
        if not text:
            raise ValueError("Empty duration string")
    
        total_seconds = 0.0
    
        # Split into parts, handling both spaces and non-spaces
        parts = []
        current_part = ""
        for char in text:
            if char.isdigit() or char == '.':
                current_part += char
            else:
                if current_part:
                    parts.append(current_part)
                    current_part = ""
                parts.append(char)
        if current_part:
            parts.append(current_part)
    
        # Merge parts to separate numbers and units
        merged_parts = []
        i = 0
        while i < len(parts):
            if parts[i].isdigit() or parts[i] == '.':
                num_str = parts[i]
                i += 1
                unit_str = ""
                while i < len(parts) and not (parts[i].isdigit() or parts[i] == '.'):
                    unit_str += parts[i]
                    i += 1
                merged_parts.append((num_str, unit_str.strip()))
            else:
                i += 1
    
        for num_str, unit_str in merged_parts:
            try:
                num = float(num_str)
            except ValueError:
                raise ValueError(f"Invalid number in duration: {num_str}")
    
            if not unit_str:
                raise ValueError(f"Missing unit for value: {num_str}")
    
            # Map unit to seconds
            unit_seconds = {
                "second": 1,
                "seconds": 1,
                "sec": 1,
                "s": 1,
                "minute": 60,
                "minutes": 60,
                "min": 60,
                "m": 60,
                "hour": 3600,
                "hours": 3600,
                "hr": 3600,
                "h": 3600,
                "day": 86400,
                "days": 86400,
                "d": 86400,
                "week": 604800,
                "weeks": 604800,
                "w": 604800,
                "month": 2592000,
                "months": 2592000,
                "year": 31536000,
                "years": 31536000,
                "y": 31536000,
            }.get(unit_str, None)
    
            if unit_seconds is None:
>               raise ValueError(f"Unknown unit: {unit_str}")
E               ValueError: Unknown unit: hrs

src/whenwords/relative.py:180: ValueError
_______________________ test_parse_duration[test_case25] _______________________

test_case = {'input': '30mins', 'name': 'minutes mins', 'output': 1800}

    @pytest.mark.parametrize("test_case", PARSE_DURATION_TEST_CASES)
    def test_parse_duration(test_case):
        """Test parse_duration function with various duration strings"""
        input_str = test_case["input"]
        expected = test_case["output"]
    
        if test_case.get("error"):
            # Test error case
            with pytest.raises(ValueError):
                parse_duration(input_str)
        else:
            # Test normal case
>           result = parse_duration(input_str)
                     ^^^^^^^^^^^^^^^^^^^^^^^^^

tests/test_relative.py:189: 
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 

text = '30mins'

    def parse_duration(text: str) -> int | float:
        text = text.strip().lower()
    
        if not text:
            raise ValueError("Empty duration string")
    
        total_seconds = 0.0
    
        # Split into parts, handling both spaces and non-spaces
        parts = []
        current_part = ""
        for char in text:
            if char.isdigit() or char == '.':
                current_part += char
            else:
                if current_part:
                    parts.append(current_part)
                    current_part = ""
                parts.append(char)
        if current_part:
            parts.append(current_part)
    
        # Merge parts to separate numbers and units
        merged_parts = []
        i = 0
        while i < len(parts):
            if parts[i].isdigit() or parts[i] == '.':
                num_str = parts[i]
                i += 1
                unit_str = ""
                while i < len(parts) and not (parts[i].isdigit() or parts[i] == '.'):
                    unit_str += parts[i]
                    i += 1
                merged_parts.append((num_str, unit_str.strip()))
            else:
                i += 1
    
        for num_str, unit_str in merged_parts:
            try:
                num = float(num_str)
            except ValueError:
                raise ValueError(f"Invalid number in duration: {num_str}")
    
            if not unit_str:
                raise ValueError(f"Missing unit for value: {num_str}")
    
            # Map unit to seconds
            unit_seconds = {
                "second": 1,
                "seconds": 1,
                "sec": 1,
                "s": 1,
                "minute": 60,
                "minutes": 60,
                "min": 60,
                "m": 60,
                "hour": 3600,
                "hours": 3600,
                "hr": 3600,
                "h": 3600,
                "day": 86400,
                "days": 86400,
                "d": 86400,
                "week": 604800,
                "weeks": 604800,
                "w": 604800,
                "month": 2592000,
                "months": 2592000,
                "year": 31536000,
                "years": 31536000,
                "y": 31536000,
            }.get(unit_str, None)
    
            if unit_seconds is None:
>               raise ValueError(f"Unknown unit: {unit_str}")
E               ValueError: Unknown unit: mins

src/whenwords/relative.py:180: ValueError
_______________________ test_parse_duration[test_case28] _______________________

test_case = {'error': True, 'input': '', 'name': 'error - empty string'}

    @pytest.mark.parametrize("test_case", PARSE_DURATION_TEST_CASES)
    def test_parse_duration(test_case):
        """Test parse_duration function with various duration strings"""
        input_str = test_case["input"]
>       expected = test_case["output"]
                   ^^^^^^^^^^^^^^^^^^^
E       KeyError: 'output'

tests/test_relative.py:181: KeyError
_______________________ test_parse_duration[test_case29] _______________________

test_case = {'error': True, 'input': 'hello world', 'name': 'error - no units'}

    @pytest.mark.parametrize("test_case", PARSE_DURATION_TEST_CASES)
    def test_parse_duration(test_case):
        """Test parse_duration function with various duration strings"""
        input_str = test_case["input"]
>       expected = test_case["output"]
                   ^^^^^^^^^^^^^^^^^^^
E       KeyError: 'output'

tests/test_relative.py:181: KeyError
_______________________ test_parse_duration[test_case30] _______________________

test_case = {'error': True, 'input': '-5 hours', 'name': 'error - negative'}

    @pytest.mark.parametrize("test_case", PARSE_DURATION_TEST_CASES)
    def test_parse_duration(test_case):
        """Test parse_duration function with various duration strings"""
        input_str = test_case["input"]
>       expected = test_case["output"]
                   ^^^^^^^^^^^^^^^^^^^
E       KeyError: 'output'

tests/test_relative.py:181: KeyError
_______________________ test_parse_duration[test_case31] _______________________

test_case = {'error': True, 'input': '42', 'name': 'error - just number'}

    @pytest.mark.parametrize("test_case", PARSE_DURATION_TEST_CASES)
    def test_parse_duration(test_case):
        """Test parse_duration function with various duration strings"""
        input_str = test_case["input"]
>       expected = test_case["output"]
                   ^^^^^^^^^^^^^^^^^^^
E       KeyError: 'output'

tests/test_relative.py:181: KeyError
=========================== short test summary info ============================
FAILED tests/test_relative.py::test_timeago[test_case1] - AssertionError: ass...
FAILED tests/test_relative.py::test_timeago[test_case2] - AssertionError: ass...
FAILED tests/test_relative.py::test_timeago[test_case3] - AssertionError: ass...
FAILED tests/test_relative.py::test_timeago[test_case5] - AssertionError: ass...
FAILED tests/test_relative.py::test_timeago[test_case8] - AssertionError: ass...
FAILED tests/test_relative.py::test_timeago[test_case10] - AssertionError: as...
FAILED tests/test_relative.py::test_timeago[test_case13] - AssertionError: as...
FAILED tests/test_relative.py::test_timeago[test_case15] - AssertionError: as...
FAILED tests/test_relative.py::test_timeago[test_case18] - AssertionError: as...
FAILED tests/test_relative.py::test_timeago[test_case20] - AssertionError: as...
FAILED tests/test_relative.py::test_timeago[test_case22] - AssertionError: as...
FAILED tests/test_relative.py::test_timeago[test_case23] - AssertionError: as...
FAILED tests/test_relative.py::test_timeago[test_case25] - AssertionError: as...
FAILED tests/test_relative.py::test_timeago[test_case27] - AssertionError: as...
FAILED tests/test_relative.py::test_timeago[test_case30] - AssertionError: as...
FAILED tests/test_relative.py::test_timeago[test_case32] - AssertionError: as...
FAILED tests/test_relative.py::test_duration[test_case13] - AssertionError: a...
FAILED tests/test_relative.py::test_duration[test_case14] - AssertionError: a...
FAILED tests/test_relative.py::test_duration[test_case15] - AssertionError: a...
FAILED tests/test_relative.py::test_duration[test_case20] - AssertionError: a...
FAILED tests/test_relative.py::test_duration[test_case24] - AssertionError: a...
FAILED tests/test_relative.py::test_duration[test_case25] - KeyError: 'output'
FAILED tests/test_relative.py::test_parse_duration[test_case2] - ValueError: ...
FAILED tests/test_relative.py::test_parse_duration[test_case4] - ValueError: ...
FAILED tests/test_relative.py::test_parse_duration[test_case5] - ValueError: ...
FAILED tests/test_relative.py::test_parse_duration[test_case6] - assert 0.0 =...
FAILED tests/test_relative.py::test_parse_duration[test_case7] - assert 0.0 =...
FAILED tests/test_relative.py::test_parse_duration[test_case11] - ValueError:...
FAILED tests/test_relative.py::test_parse_duration[test_case12] - ValueError:...
FAILED tests/test_relative.py::test_parse_duration[test_case13] - ValueError:...
FAILED tests/test_relative.py::test_parse_duration[test_case18] - ValueError:...
FAILED tests/test_relative.py::test_parse_duration[test_case24] - ValueError:...
FAILED tests/test_relative.py::test_parse_duration[test_case25] - ValueError:...
FAILED tests/test_relative.py::test_parse_duration[test_case28] - KeyError: '...
FAILED tests/test_relative.py::test_parse_duration[test_case29] - KeyError: '...
FAILED tests/test_relative.py::test_parse_duration[test_case30] - KeyError: '...
FAILED tests/test_relative.py::test_parse_duration[test_case31] - KeyError: '...
======================== 37 failed, 57 passed in 0.13s =========================
```
</error_output>

<verify_command>
python -m pytest tests/test_relative.py -v
</verify_command>

<current_file path="tests/test_relative.py">
```
"""Tests for the relative time module using test cases from tests.yaml"""
import pytest
from datetime import datetime
from src.whenwords.relative import timeago, duration, parse_duration


# Timeago test cases
TIMEAGO_TEST_CASES = [
    # just now cases
    {"name": "just now - identical timestamps", "input": {"timestamp": 1704067200, "reference": 1704067200}, "output": "just now"},
    {"name": "just now - 30 seconds ago", "input": {"timestamp": 1704067170, "reference": 1704067200}, "output": "just now"},
    {"name": "just now - 44 seconds ago", "input": {"timestamp": 1704067156, "reference": 1704067200}, "output": "just now"},
    
    # minutes
    {"name": "1 minute ago - 45 seconds", "input": {"timestamp": 1704067155, "reference": 1704067200}, "output": "1 minute ago"},
    {"name": "1 minute ago - 89 seconds", "input": {"timestamp": 1704067111, "reference": 1704067200}, "output": "1 minute ago"},
    {"name": "2 minutes ago - 90 seconds", "input": {"timestamp": 1704067110, "reference": 1704067200}, "output": "2 minutes ago"},
    {"name": "30 minutes ago", "input": {"timestamp": 1704065400, "reference": 1704067200}, "output": "30 minutes ago"},
    {"name": "44 minutes ago", "input": {"timestamp": 1704064560, "reference": 1704067200}, "output": "44 minutes ago"},
    
    # hours
    {"name": "1 hour ago - 45 minutes", "input": {"timestamp": 1704064500, "reference": 1704067200}, "output": "1 hour ago"},
    {"name": "1 hour ago - 89 minutes", "input": {"timestamp": 1704061860, "reference": 1704067200}, "output": "1 hour ago"},
    {"name": "2 hours ago - 90 minutes", "input": {"timestamp": 1704061800, "reference": 1704067200}, "output": "2 hours ago"},
    {"name": "5 hours ago", "input": {"timestamp": 1704049200, "reference": 1704067200}, "output": "5 hours ago"},
    {"name": "21 hours ago", "input": {"timestamp": 1703991600, "reference": 1704067200}, "output": "21 hours ago"},
    
    # days
    {"name": "1 day ago - 22 hours", "input": {"timestamp": 1703988000, "reference": 1704067200}, "output": "1 day ago"},
    {"name": "1 day ago - 35 hours", "input": {"timestamp": 1703941200, "reference": 1704067200}, "output": "1 day ago"},
    {"name": "2 days ago - 36 hours", "input": {"timestamp": 1703937600, "reference": 1704067200}, "output": "2 days ago"},
    {"name": "7 days ago", "input": {"timestamp": 1703462400, "reference": 1704067200}, "output": "7 days ago"},
    {"name": "25 days ago", "input": {"timestamp": 1701907200, "reference": 1704067200}, "output": "25 days ago"},
    
    # months
    {"name": "1 month ago - 26 days", "input": {"timestamp": 1701820800, "reference": 1704067200}, "output": "1 month ago"},
    {"name": "1 month ago - 45 days", "input": {"timestamp": 1700179200, "reference": 1704067200}, "output": "1 month ago"},
    {"name": "2 months ago - 46 days", "input": {"timestamp": 1700092800, "reference": 1704067200}, "output": "2 months ago"},
    {"name": "6 months ago", "input": {"timestamp": 1688169600, "reference": 1704067200}, "output": "6 months ago"},
    {"name": "11 months ago - 319 days", "input": {"timestamp": 1676505600, "reference": 1704067200}, "output": "11 months ago"},
    
    # years
    {"name": "1 year ago - 320 days", "input": {"timestamp": 1676419200, "reference": 1704067200}, "output": "1 year ago"},
    {"name": "1 year ago - 547 days", "input": {"timestamp": 1656806400, "reference": 1704067200}, "output": "1 year ago"},
    {"name": "2 years ago - 548 days", "input": {"timestamp": 1656720000, "reference": 1704067200}, "output": "2 years ago"},
    {"name": "5 years ago", "input": {"timestamp": 1546300800, "reference": 1704067200}, "output": "5 years ago"},
    
    # future
    {"name": "future - in just now (30 seconds)", "input": {"timestamp": 1704067230, "reference": 1704067200}, "output": "just now"},
    {"name": "future - in 1 minute", "input": {"timestamp": 1704067260, "reference": 1704067200}, "output": "in 1 minute"},
    {"name": "future - in 5 minutes", "input": {"timestamp": 1704067500, "reference": 1704067200}, "output": "in 5 minutes"},
    {"name": "future - in 1 hour", "input": {"timestamp": 1704070200, "reference": 1704067200}, "output": "in 1 hour"},
    {"name": "future - in 3 hours", "input": {"timestamp": 1704078000, "reference": 1704067200}, "output": "in 3 hours"},
    {"name": "future - in 1 day", "input": {"timestamp": 1704150000, "reference": 1704067200}, "output": "in 1 day"},
    {"name": "future - in 2 days", "input": {"timestamp": 1704240000, "reference": 1704067200}, "output": "in 2 days"},
    {"name": "future - in 1 month", "input": {"timestamp": 1706745600, "reference": 1704067200}, "output": "in 1 month"},
    {"name": "future - in 1 year", "input": {"timestamp": 1735689600, "reference": 1704067200}, "output": "in 1 year"},
]


# Duration test cases
DURATION_TEST_CASES = [
    {"name": "zero seconds", "input": {"seconds": 0}, "output": "0 seconds"},
    {"name": "1 second", "input": {"seconds": 1}, "output": "1 second"},
    {"name": "45 seconds", "input": {"seconds": 45}, "output": "45 seconds"},
    {"name": "1 minute", "input": {"seconds": 60}, "output": "1 minute"},
    {"name": "1 minute 30 seconds", "input": {"seconds": 90}, "output": "1 minute, 30 seconds"},
    {"name": "2 minutes", "input": {"seconds": 120}, "output": "2 minutes"},
    {"name": "1 hour", "input": {"seconds": 3600}, "output": "1 hour"},
    {"name": "1 hour 1 minute", "input": {"seconds": 3661}, "output": "1 hour, 1 minute"},
    {"name": "1 hour 30 minutes", "input": {"seconds": 5400}, "output": "1 hour, 30 minutes"},
    {"name": "2 hours 30 minutes", "input": {"seconds": 9000}, "output": "2 hours, 30 minutes"},
    {"name": "1 day", "input": {"seconds": 86400}, "output": "1 day"},
    {"name": "1 day 2 hours", "input": {"seconds": 93600}, "output": "1 day, 2 hours"},
    {"name": "7 days", "input": {"seconds": 604800}, "output": "7 days"},
    {"name": "1 month (30 days)", "input": {"seconds": 2592000}, "output": "1 month"},
    {"name": "1 year (365 days)", "input": {"seconds": 31536000}, "output": "1 year"},
    {"name": "1 year 2 months", "input": {"seconds": 36720000}, "output": "1 year, 2 months"},
    
    # Compact format
    {"name": "compact - 1h 1m", "input": {"seconds": 3661, "options": {"compact": True}}, "output": "1h 1m"},
    {"name": "compact - 2h 30m", "input": {"seconds": 9000, "options": {"compact": True}}, "output": "2h 30m"},
    {"name": "compact - 1d 2h", "input": {"seconds": 93600, "options": {"compact": True}}, "output": "1d 2h"},
    {"name": "compact - 45s", "input": {"seconds": 45, "options": {"compact": True}}, "output": "45s"},
    {"name": "compact - 0s", "input": {"seconds": 0, "options": {"compact": True}}, "output": "0s"},
    
    # max_units
    {"name": "max_units 1 - hours only", "input": {"seconds": 3661, "options": {"max_units": 1}}, "output": "1 hour"},
    {"name": "max_units 1 - days only", "input": {"seconds": 93600, "options": {"max_units": 1}}, "output": "1 day"},
    {"name": "max_units 3", "input": {"seconds": 93661, "options": {"max_units": 3}}, "output": "1 day, 2 hours, 1 minute"},
    {"name": "compact max_units 1", "input": {"seconds": 9000, "options": {"compact": True, "max_units": 1}}, "output": "3h"},
    
    # Error case
    {"name": "error - negative seconds", "input": {"seconds": -100}, "error": True},
]


# Parse duration test cases
PARSE_DURATION_TEST_CASES = [
    {"name": "compact hours minutes", "input": "2h30m", "output": 9000},
    {"name": "compact with space", "input": "2h 30m", "output": 9000},
    {"name": "compact with comma", "input": "2h, 30m", "output": 9000},
    {"name": "verbose", "input": "2 hours 30 minutes", "output": 9000},
    {"name": "verbose with and", "input": "2 hours and 30 minutes", "output": 9000},
    {"name": "verbose with comma and", "input": "2 hours, and 30 minutes", "output": 9000},
    {"name": "decimal hours", "input": "2.5 hours", "output": 9000},
    {"name": "decimal compact", "input": "1.5h", "output": 5400},
    {"name": "single unit minutes verbose", "input": "90 minutes", "output": 5400},
    {"name": "single unit minutes compact", "input": "90m", "output": 5400},
    {"name": "single unit min", "input": "90min", "output": 5400},
    {"name": "colon notation h:mm", "input": "2:30", "output": 9000},
    {"name": "colon notation h:mm:ss", "input": "1:30:00", "output": 5400},
    {"name": "colon notation with seconds", "input": "0:05:30", "output": 330},
    {"name": "days verbose", "input": "2 days", "output": 172800},
    {"name": "days compact", "input": "2d", "output": 172800},
    {"name": "weeks verbose", "input": "1 week", "output": 604800},
    {"name": "weeks compact", "input": "1w", "output": 604800},
    {"name": "mixed verbose", "input": "1 day, 2 hours, and 30 minutes", "output": 95400},
    {"name": "mixed compact", "input": "1d 2h 30m", "output": 95400},
    {"name": "seconds only verbose", "input": "45 seconds", "output": 45},
    {"name": "seconds compact s", "input": "45s", "output": 45},
    {"name": "seconds compact sec", "input": "45sec", "output": 45},
    {"name": "hours hr", "input": "2hr", "output": 7200},
    {"name": "hours hrs", "input": "2hrs", "output": 7200},
    {"name": "minutes mins", "input": "30mins", "output": 1800},
    {"name": "case insensitive", "input": "2H 30M", "output": 9000},
    {"name": "whitespace tolerance", "input": "  2 hours   30 minutes  ", "output": 9000},
    
    # Error cases
    {"name": "error - empty string", "input": "", "error": True},
    {"name": "error - no units", "input": "hello world", "error": True},
    {"name": "error - negative", "input": "-5 hours", "error": True},
    {"name": "error - just number", "input": "42", "error": True},
]


@pytest.mark.parametrize("test_case", TIMEAGO_TEST_CASES)
def test_timeago(test_case):
    """Test timeago function with various timestamp differences"""
    input_data = test_case["input"]
    expected = test_case["output"]
    
    # Test with Unix timestamps
    result = timeago(input_data["timestamp"], input_data["reference"])
    assert result == expected
    
    # Test with datetime objects
    timestamp_dt = datetime.fromtimestamp(input_data["timestamp"])
    reference_dt = datetime.fromtimestamp(input_data["reference"])
    result_dt = timeago(timestamp_dt, reference_dt)
    assert result_dt == expected
    
    # Test with ISO 8601 strings
    timestamp_iso = datetime.fromtimestamp(input_data["timestamp"]).isoformat()
    reference_iso = datetime.fromtimestamp(input_data["reference"]).isoformat()
    result_iso = timeago(timestamp_iso, reference_iso)
    assert result_iso == expected


@pytest.mark.parametrize("test_case", DURATION_TEST_CASES)
def test_duration(test_case):
    """Test duration function with various second values and options"""
    input_data = test_case["input"]
    expected = test_case["output"]
    
    if test_case.get("error"):
        # Test error case
        with pytest.raises(ValueError):
            duration(input_data["seconds"])
    else:
        # Test normal case
        options = input_data.get("options")
        result = duration(input_data["seconds"], options)
        assert result == expected


@pytest.mark.parametrize("test_case", PARSE_DURATION_TEST_CASES)
def test_parse_duration(test_case):
    """Test parse_duration function with various duration strings"""
    input_str = test_case["input"]
    expected = test_case["output"]
    
    if test_case.get("error"):
        # Test error case
        with pytest.raises(ValueError):
            parse_duration(input_str)
    else:
        # Test normal case
        result = parse_duration(input_str)
        assert result == expected

```
</current_file>

<task>
**Relative Time Module Tests**: Create tests for the relative time functions using the test cases from tests.yaml.
</task>