path = require 'path'
CSON = require 'season'
fs = require 'fs-plus'

module.exports = (grunt) ->
  {spawn} = require('./task-helpers')(grunt)

  grunt.registerTask 'compile-packages-slug', 'Build the packages.json file', ->
    appDir = grunt.config.get('atom.appDir')

    packagesJsonPath = path.join(appDir, 'packages.json')
    modulesDirectory = path.join(appDir, 'node_modules')

    packages = {}

    for moduleDirectory in fs.listSync(modulesDirectory)
      continue if path.basename(moduleDirectory) is '.bin'

      metadata = grunt.file.readJSON(path.join(moduleDirectory, 'package.json'))
      continue unless metadata?.engines?.atom?

      pack = {metadata, keymaps: {}, menus: {}}

      for keymapPath in fs.listSync(path.join(moduleDirectory, 'keymaps'), ['.cson', '.json'])
        pack.keymaps[keymapPath] = CSON.readFileSync(keymapPath)

      for menuPath in fs.listSync(path.join(moduleDirectory, 'menus'), ['.cson', '.json'])
        pack.menus[menuPath] = CSON.readFileSync(menuPath)

      packages[metadata.name] = pack

    grunt.file.write(packagesJsonPath, JSON.stringify(packages))
