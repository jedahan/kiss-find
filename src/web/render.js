async function readFile(filename = '/dev/stdin') {
  const buffer = new Uint8Array(1024)

  const handle = await tjs.fs.open(filename, 'r')
  let csv = ''
  let length = await handle.read(buffer)
  while (length) {
    csv += new TextDecoder().decode(buffer)
    length = await handle.read(buffer)
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
  const search = new TextDecoder().decode(await tjs.fs.readFile('src/web/search.js'))
  const sort = new TextDecoder().decode(await tjs.fs.readFile('src/web/sort.js'))
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

      const unquote = (string) => string?.slice(1)?.slice(0, -1)

      const a = (url, name) =>
        `<a href=${url} class=url>${name ?? url?.replace('https://', '')}</a>`

      const td = (name, content) => `<td class=${name}>${content}</td>`

      const package = [
        `<tr>`,
        [
          '  ' + td('name', a(href(uri ?? ''), name)),
          td('version', version?.split(' ')[0]),
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

  const stats = {
    packages: new Set(packages.map((info) => info[0])).size,
    repositories: new Set(packages.map((info) => info[2])).size,
    maintainers: new Set(packages.map((info) => info[5])).size,
  }

  console.log(html`
<head>
  <meta charset=utf-8 />
  <title>kiss find</title>
  <link href="data:image/gif;base64,R0lGODlhEAAQAPH/AAAAAP8AAP8AN////yH5BAUAAAQALAAAAAAQABAAAAM2SLrc/jA+QBUFM2iqA2bAMHSktwCCWJIYEIyvKLOuJt+wV69ry5cfwu7WCVp2RSPoUpE4n4sEADs=" rel="icon">
  <script>
    ${search}
  </script>
  <script>
    ${sort}
  </script>
  <style>
    ${style}
  </style>
</head>

<body>
  <h1>kiss find</h1>
  <p>
    <span>${stats.packages} packages by ${stats.maintainers} maintainers across ${stats.repositories} repositories</span>
    (<a href=https://github.com/jedahan/kiss-find/>source</a>)
  </p>

  <input list=names type=search placeholder=search class=hidden autofocus/>
  <span> <span id=count>${packages.length}</span> matches</span>
  <span> (<span id=uniques>${names.length}</span> unique)</span>
  <datalist id=names>
    ${datalist}
  </datalist>
  <table id=sortable>
    <thead>
      <tr id=header>
        <th><a href=# id=nameHeader>name</a></th>
        <th><a href=# id=versionHeader>version</a></th>
        <th><a href=# id=urlHeader>url</a></th>
        <th><a href=# id=maintainerHeader>maintainer</a></th>
        <th><a href=# id=descriptionHeader>description</a></th>
      </tr>
    </thead>
    <tbody id=packages>
      ${tbody}
    </tbody>
  </table>
</body>
  `)
})()
