async function readFile(filename='/dev/stdin') {
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

(async () => {
  const csv = await readFile()
  const packages = csv.split('\n')
    .filter(line => line !== '')
    .map(entry => entry.split(','))
    .map(([name, version, uri, path, branch, description]) => {
      const href = (url) => {
        if (url.includes('sr.ht/')) return [url, 'tree', branch, 'item', path].join('/')
        if (url.includes('github.com/')) return [url, 'tree', branch, path].join('/')
        return url
      }

      function a(url, name) {
        const text = name ?? url?.replace('https://','')
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
          ].join("\n        "),
        `</tr>`
      ].join("\n      ")
      return package
    })

  const body = `
  <head>
  <script>
    function init() {
      const input = document.getElementsByTagName('input')[0]
      input.oninput = (event) => {
        const needle = event.target.value.trim()

        Array.from(document.getElementsByTagName('tr'))
          .forEach(element => {
            const found = needle.length === 0
              || element.firstChild.textContent.includes(needle)
              || element.children[2].textContent.includes(needle)
              || element.lastChild.textContent.includes(needle)
            element.className = found ? '' : 'hidden'
          })
      }
    }

    window.onload = init
  </script>
  <style>
    .hidden {
      display: none;
    }
    tr td {
      min-width: max-content;
    }
    tr td:nth-child(2) {
      max-width: 10em;
      min-width: 10em;
      text-overflow: ellipsis;
      overflow: hidden;
    }


    /* Sakura.css v1.3.1
    * ================
    * Minimal css theme.
    * Project: https://github.com/oxalorg/sakura/
    */
    /* Body */
    html {
      font-size: 62.5%;
      font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, "Noto Sans", sans-serif;
    }

    body {
      font-size: 1.8rem;
      line-height: 1.618;
      max-width: 38em;
      /* margin: auto; */
      color: #49002d;
      background-color: #ffe4f5;
      padding: 13px;
    }

    @media (max-width: 684px) {
      body {
        font-size: 1.53rem;
      }
    }

    @media (max-width: 382px) {
      body {
        font-size: 1.35rem;
      }
    }

    h1,
    h2,
    h3,
    h4,
    h5,
    h6 {
      line-height: 1.1;
      font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, "Noto Sans", sans-serif;
      font-weight: 700;
      margin-top: 3rem;
      margin-bottom: 1.5rem;
      overflow-wrap: break-word;
      word-wrap: break-word;
      -ms-word-break: break-all;
      word-break: break-word;
    }

    h1 {
      font-size: 2.35em;
    }

    h2 {
      font-size: 2.00em;
    }

    h3 {
      font-size: 1.75em;
    }

    h4 {
      font-size: 1.5em;
    }

    h5 {
      font-size: 1.25em;
    }

    h6 {
      font-size: 1em;
    }

    p {
      margin-top: 0px;
      margin-bottom: 2.5rem;
    }

    small,
    sub,
    sup {
      font-size: 75%;
    }

    hr {
      border-color: #980255;
    }

    a {
      text-decoration: none;
      color: #980255;
    }

    a:hover {
      color: #753851;
      border-bottom: 2px solid #49002d;
    }

    a:visited {
      color: #660139;
    }

    ul {
      padding-left: 1.4em;
      margin-top: 0px;
      margin-bottom: 2.5rem;
    }

    li {
      margin-bottom: 0.4em;
    }

    blockquote {
      margin-left: 0px;
      margin-right: 0px;
      padding-left: 1em;
      padding-top: 0.8em;
      padding-bottom: 0.8em;
      padding-right: 0.8em;
      border-left: 5px solid #980255;
      margin-bottom: 2.5rem;
      background-color: #f8d2e9;
    }

    blockquote p {
      margin-bottom: 0;
    }

    img,
    video {
      height: auto;
      max-width: 100%;
      margin-top: 0px;
      margin-bottom: 2.5rem;
    }

    /* Pre and Code */
    pre {
      background-color: #f8d2e9;
      display: block;
      padding: 1em;
      overflow-x: auto;
      margin-top: 0px;
      margin-bottom: 2.5rem;
    }

    code {
      font-size: 0.9em;
      padding: 0 0.5em;
      background-color: #f8d2e9;
      white-space: pre-wrap;
    }

    pre>code {
      padding: 0;
      background-color: transparent;
      white-space: pre;
    }

    /* Tables */
    table {
      text-align: justify;
      width: 100%;
      border-collapse: collapse;
    }

    td,
    th {
      padding: 0.5em;
      border-bottom: 1px solid #f8d2e9;
    }

    /* Buttons, forms and input */
    input,
    textarea {
      border: 1px solid #49002d;
    }

    input:focus,
    textarea:focus {
      border: 1px solid #980255;
    }

    textarea {
      width: 100%;
    }

    .button,
    button,
    input[type="submit"],
    input[type="reset"],
    input[type="button"] {
      display: inline-block;
      padding: 5px 10px;
      text-align: center;
      text-decoration: none;
      white-space: nowrap;
      background-color: #980255;
      color: #ffe4f5;
      border-radius: 1px;
      border: 1px solid #980255;
      cursor: pointer;
      box-sizing: border-box;
    }

    .button[disabled],
    button[disabled],
    input[type="submit"][disabled],
    input[type="reset"][disabled],
    input[type="button"][disabled] {
      cursor: default;
      opacity: .5;
    }

    .button:focus:enabled,
    .button:hover:enabled,
    button:focus:enabled,
    button:hover:enabled,
    input[type="submit"]:focus:enabled,
    input[type="submit"]:hover:enabled,
    input[type="reset"]:focus:enabled,
    input[type="reset"]:hover:enabled,
    input[type="button"]:focus:enabled,
    input[type="button"]:hover:enabled {
      background-color: #753851;
      border-color: #753851;
      color: #ffe4f5;
      outline: 0;
    }

    textarea,
    select,
    input {
      color: #49002d;
      padding: 6px 10px;
      /* The 6px vertically centers text on FF, ignored by Webkit */
      margin-bottom: 10px;
      background-color: #f8d2e9;
      border: 1px solid #f8d2e9;
      border-radius: 4px;
      box-shadow: none;
      box-sizing: border-box;
    }

    textarea:focus,
    select:focus,
    input:focus {
      border: 1px solid #980255;
      outline: 0;
    }

    input[type="checkbox"]:focus {
      outline: 1px dotted #980255;
    }

    label,
    legend,
    fieldset {
      display: block;
      margin-bottom: .5rem;
      font-weight: 600;
    }
  </style>
</head>

<body>
  <h1>Kiss find (<a href=https://github.com/jedahan/kiss-find/>source</a>)</h1>
  <input type=search placeholder=search autofocus />
  <table id=packages>
    <thead>
      <tr>
      <th>name</th>
      <th>version</th>
      <th>url</th>
      <th>description</th>
    </tr>
    </thead>
    <tbody id=packagesBody>
      __BODY__
    </tbody>
  </table>
</body>

  `

  console.log(body.replace('__BODY__', packages.join("\n      ")))
})()