const http = require("http")
const myHostName = process.env.HOSTNAME

const hostname = "localhost"
const port = 3000

const server = http.createServer((req, res) => {
  if (req.url === "/health") {
    res.statusCode = 200
    res.setHeader("Content-Type", "text/plain")
    res.end("health ok\n")
  } else {
    res.statusCode = 200
    res.setHeader("Content-Type", "text/plain")
    res.end(`Hello, I'm ${myHostName}\n`)
  }
})

server.listen(port, hostname, () => {
  console.log(`Server running`)
})
