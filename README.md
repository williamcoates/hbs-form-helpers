# Form input helpers for express-hbs

## Install

    npm install hbs-form-helpers

## Setup

    hbs = require 'express-hbs'
    FormHelpers = require 'hbs-form-helpers'
    FormHelpers.registerHelpers(hbs)

## Use in your views


    {{emailInput 'email' placeholder='Enter your email' required=true}}