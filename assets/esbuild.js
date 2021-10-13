const esbuild = require('esbuild')
const {sassPlugin} = require("esbuild-sass-plugin")

// Decide which mode to proceed with
let mode = 'build'
process.argv.slice(2).forEach((arg) => {
  if (arg === '--watch') {
    mode = 'watch'
  } else if (arg === '--deploy') {
    mode = 'deploy'
  }
})

// Define esbuild options + extras for watch and deploy
let opts = {
  entryPoints: ['js/app.js'],
  outdir: '../priv/static/assets',
  bundle: true,
  logLevel: 'info',
  target: 'es2015',
  loader: { // built-in loaders: js, jsx, ts, tsx, css, json, text, base64, dataurl, file, binary
      '.ttf': 'file',
      '.svg': 'file',
      '.woff': 'file',
    },
  plugins: [sassPlugin({cache: true})],
}
if (mode === 'watch') {
  opts = {
    watch: true,
    sourcemap: 'inline',
    ...opts
  }
}
if (mode === 'deploy') {
  opts = {
    minify: true,
    ...opts
  }
}

// Start esbuild with previously defined options
// Stop the watcher when STDIN gets closed (no zombies please!)
esbuild.build(opts).then((result) => {
  if (mode === 'watch') {
    process.stdin.pipe(process.stdout)
    process.stdin.on('end', () => { result.stop() })
  }
}).catch((error) => {
  process.exit(1)
})