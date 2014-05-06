-- Copyright 2014 Nils Nordman <nino at nordman.org>
-- License: MIT (see LICENSE)

ffi = require 'ffi'
jit = require 'jit'
require 'ljglibs.cdefs.gio'
glib = require 'ljglibs.glib'
core = require 'ljglibs.core'
gobject = require 'ljglibs.gobject'
import gc_ptr, signal, object from gobject
import catch_error from glib

C = ffi.C
ffi_string, ffi_cast = ffi.string, ffi.cast

Application = core.define 'GApplication < GObject', {
  constants: {
    prefix: 'G_APPLICATION_'

    -- GApplicationFlags
    'FLAGS_NONE',
    'IS_SERVICE',
    'IS_LAUNCHER',
    'HANDLES_OPEN',
    'HANDLES_COMMAND_LINE',
    'SEND_ENVIRONMENT',
    'NON_UNIQUE'
  }

  properties: {
    flags: => C.g_application_get_flags @
    application_id: 'gchar*'
  }

  register: => catch_error(C.g_application_register, @, nil) != 0
  release: => C.g_application_release @
  quit: => C.g_application_quit @

  run: (args) =>
    argv = ffi.new 'char*[?]', #args
    for i = 0, #args - 1
      arg = args[i + 1]
      argv[i] = ffi.new 'char [?]', #arg + 1, arg
    C.g_application_run @, #args, argv

  on_open: (handler, ...) =>
    signal.connect 'void5', @, 'open', (app, files, n_files, hint) ->
      gfiles = {}
      n_files = tonumber ffi_cast('gint', n_files)
      files = ffi_cast 'GFile **', files
      for i = 1, n_files
        gfiles[#gfiles + 1] = gc_ptr object.ref files[i - 1]

      handler @, gfiles, ffi_string hint

},  (t, application_id, flags = t.FLAGS_NONE) ->
  gc_ptr(C.g_application_new application_id, flags)

jit.off Application.run

Application
