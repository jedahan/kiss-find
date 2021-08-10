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
    .map(([name, version, uri, path, branch, description]) => {
      const href = (url) => {
        if (url.includes('sr.ht/')) return [url, 'tree', branch, 'item', path].join('/')
        if (url.includes('github.com/')) return [url, 'tree', branch, path].join('/')
        return url
      }

      function a(url, name) {
        const text = name ?? url?.replace('https://', '')
        return `<a href=${url}>${text}</a>`
      }

      const td = (name, content) => `<td class=${name}>${content}</td>`

      const package = [
        `<tr>`,
        [
          '  ' + td('name', a(href(uri ?? ''), name)),
          td('version', version),
          td('url', a(uri)),
          td('description', description),
        ].join('\n        '),
        `</tr>`,
      ].join('\n      ')
      return package
    })
    .join('\n      ')

  const datalist = Array.from(new Set(packages))
    .map(([name]) => `<option value="${name}">`)
    .join('\n      ')

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
  <input list=packages type=search placeholder=search class=hidden autofocus/>
  <span> <span id=count>${packages.length}</span> packages</span>
  <datalist id=packages>
    ${datalist}
  </datalist>
  <table>
    <thead>
      <tr>
      <th>name</th>
      <th>version</th>
      <th>url</th>
      <th>description</th>
    </tr>
    </thead>
    <tbody>
      ${tbody}
    </tbody>
  </table>
</body>
  `)
})()
