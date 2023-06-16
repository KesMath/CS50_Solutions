import csv
import datetime
import pytz
import requests
import subprocess
import urllib
import uuid

from flask import redirect, render_template, session
from functools import wraps


def apology(message, code=400):
    """Render message as an apology to user."""
    def escape(s):
        """
        Escape special characters.

        https://github.com/jacebrowning/memegen#special-characters
        """
        for old, new in [("-", "--"), (" ", "-"), ("_", "__"), ("?", "~q"),
                         ("%", "~p"), ("#", "~h"), ("/", "~s"), ("\"", "''")]:
            s = s.replace(old, new)
        return s
    return render_template("apology.html", top=code, bottom=escape(message)), code


def login_required(f):
    """
    Decorate routes to require login.

    http://flask.pocoo.org/docs/0.12/patterns/viewdecorators/
    """
    @wraps(f)
    def decorated_function(*args, **kwargs):
        if session.get("user_id") is None:
            return redirect("/login")
        return f(*args, **kwargs)
    return decorated_function


def lookup(symbol):
    """Look up quote for symbol."""

    # Prepare API request
    symbol = symbol.upper()
    end = datetime.datetime.now(pytz.timezone("US/Eastern"))
    start = end - datetime.timedelta(days=7)

    # Yahoo Finance API
    url = (
        f"https://query1.finance.yahoo.com/v7/finance/download/{urllib.parse.quote_plus(symbol)}"
        f"?period1={int(start.timestamp())}"
        f"&period2={int(end.timestamp())}"
        f"&interval=1d&events=history&includeAdjustedClose=true"
    )

    # Query API
    try:
        response = requests.get(url, cookies={"session": str(uuid.uuid4())}, headers={"User-Agent": "python-requests", "Accept": "*/*"})
        response.raise_for_status()

        # CSV header: Date,Open,High,Low,Close,Adj Close,Volume
        quotes = list(csv.DictReader(response.content.decode("utf-8").splitlines()))
        quotes.reverse()
        price = round(float(quotes[0]["Adj Close"]), 2)
        return {
            "name": symbol,
            "price": price,
            "symbol": symbol
        }
    except (requests.RequestException, ValueError, KeyError, IndexError):
        return None


def usd(value):
    """Format value as USD."""
    return f"${value:,.2f}"


def validate_form_inputs(**kwargs):
    """Returns param key:val pair to show to apology if form is invalid"""
    for key, val in kwargs.items():
        if val == '':
            return key, val
        elif val is None:
            return key, None
    return None


# Refer to https://www.cs.cmu.edu/~pattis/15-1XX/common/handouts/ascii.html
# for ASCII character code mappings
def is_symbol(ch):
    return not (is_lower_case(ch) or is_upper_case(ch) or is_number(ch))


def is_lower_case(ch):
    return 97 <= ord(ch) <= 122


def is_upper_case(ch):
    return 65 <= ord(ch) <= 90


def is_number(ch):
    return 48 <= ord(ch) <= 57


def is_compliant_to_password_policy(password):
    """ Returns true if password is:
        at least 6 characters in long, contains one lower and upper case character, one symbol and number"""
    if len(password) < 6:
        return False

    else:
        is_sym = False
        is_lower = False
        is_upper = False
        is_num = False

        for ch in password:
            if is_sym and is_lower and is_upper and is_num: #early break if all 4 conditions are met
                return True

            if is_symbol(ch):
                is_sym = True
                continue

            if is_lower_case(ch):
                is_lower = True
                continue

            if is_upper_case(ch):
                is_upper = True
                continue

            if is_number(ch):
                is_num = True
                continue

        return False