// --
// OTOBO is a web-based ticketing system for service organisations.
// --
// Copyright (C) 2001-2020 OTRS AG, https://otrs.com/
// Copyright (C) 2019-2020 Rother OSS GmbH, https://otobo.de/
// --
// This program is free software: you can redistribute it and/or modify it under
// the terms of the GNU General Public License as published by the Free Software
// Foundation, either version 3 of the License, or (at your option) any later version.
// This program is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
// FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
// You should have received a copy of the GNU General Public License
// along with this program. If not, see <https://www.gnu.org/licenses/>.

module.exports = {
    "env": {
        "browser": true,
        "jquery": true
    },
    "globals": {
        "Core": true,
        "CKEDITOR": true,
        "isJQueryObject": true,
        "printStackTrace": true,
        "QUnit": true,
        // older QUnit stuff
        // only needed for OTOBO <= 5
        // can be removed later
        "module": true,
        "test": true,
        "expect": true,
        "equal": true,
        "deepEqual": true,
        "asyncTest": true,
        "start": true,
        "ok": true,
        "notEqual": true
    },
    "extends": "eslint:recommended",
    "rules": {
        "quotes": 0,
        "new-cap": 0,
        "global-strict": 0,
        "no-alert": 0,
        "radix": 2,
        "valid-jsdoc": [2, {
            "requireReturn": false,
            "requireParamDescription": false,
            "requireReturnDescription": false
        }],
        "no-catch-shadow": 0,
        "vars-on-top": 2,
        "space-in-parens": [2, "never"],
        "no-eval": 2,
        "no-implied-eval": 2,

        // OTOBO-specific rules
        "no-window": 2
    }
}
