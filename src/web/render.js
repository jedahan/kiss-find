async function readFile(filename = '/dev/stdin') {
  const buffer = new ArrayBuffer(1024)

  const handle = await tjs.fs.open(filename, 'r')
  let csv = ''
  let data = await handle.read(buffer.length)
  while (data.length) {
    csv += new TextDecoder().decode(data)
    data = await handle.read(buffer.length)
  }
  return csv
}

function html(pieces) {
  let result = pieces[0]
  const substitutions = [].slice.call(arguments, 1)
  for (var i = 0; i < substitutions.length; ++i) {
    result += substitutions[i] + pieces[i + 1]
  }

  return result
}

;(async () => {
  const script = new TextDecoder().decode(await tjs.fs.readFile('src/web/search.js'))
  const style = new TextDecoder().decode(await tjs.fs.readFile('src/web/style.css'))
  const packages = (await readFile())
    .split('\n')
    .filter((line) => line !== '')
    .map((entry) => entry.split(','))

  const tbody = packages
    .map(([name, version, uri, path, branch, maintainer, description]) => {
      function href(url) {
        if (url.includes('sr.ht/')) return [url, 'tree', branch, 'item', path].join('/')
        if (url.includes('github.com/')) return [url, 'tree', branch, path].join('/')
        if (url.startsWith('git://'))
          return [url.replace(/^git:\/\//, 'https://'), 'file', path, 'build.html'].join('/')
        return url
      }

      const unquote = (string) => string.slice(1).slice(0, -1)

      const a = (url, name) =>
        `<a href=${url} class=url>${name ?? url?.replace('https://', '')}</a>`

      const td = (name, content) => `<td class=${name}>${content}</td>`

      const package = [
        `<tr>`,
        [
          '  ' + td('name', a(href(uri ?? ''), name)),
          td('version', version.split(' ')[0]),
          td('uri', a(uri)),
          td('maintainer', unquote(maintainer)),
          td('description', unquote(description)),
        ].join('\n        '),
        `</tr>`,
      ].join('\n      ')
      return package
    })
    .join('\n      ')

  const names = Array.from(new Set(packages.map(([name]) => name)))

  const datalist = names.map((name) => `<option value="${name}">`).join('\n      ')

  console.log(html`
<head>
  <meta charset=utf-8 />
  <title>kiss find</title>
  <link href="data:image/gif;base64,R0lGODlhEAAQAPH/AAAAAP8AAP8AN////yH5BAUAAAQALAAAAAAQABAAAAM2SLrc/jA+QBUFM2iqA2bAMHSktwCCWJIYEIyvKLOuJt+wV69ry5cfwu7WCVp2RSPoUpE4n4sEADs=" rel="icon">
  <script>
    ${script}
  </script>
  <style>
    ${style}
  </style>
</head>

<body>
  <h1>Kiss find (<a href=https://github.com/jedahan/kiss-find/>source</a>)</h1>
  <input list=names type=search placeholder=search class=hidden autofocus/>
  <span> <span id=count>${packages.length}</span> packages</span>
  <span> (<span id=uniques>${names.length}</span> unique)</span>
  <datalist id=names>
    ${datalist}
  </datalist>
  <table>
    <thead>
      <tr>
      <th>name</th>
      <th>version</th>
      <th>url</th>
      <th>maintainer</th>
      <th>description</th>
    </tr>
    </thead>
    <tbody id=packages>
      ${tbody}
    </tbody>
  </table>
</body>
  `)
})()
