import email.feedparser
import email.policy
import os
import sys
import json
from socketserver import UnixStreamServer, ThreadingMixIn, BaseRequestHandler

import pyzor.client
import pyzor.digest


class RequestHandler(BaseRequestHandler):
    def handle(self):
        parser = email.feedparser.BytesFeedParser(policy=email.policy.SMTPUTF8)

        while True:
            data = self.request.recv(256)
            if len(data) == 0:
                break
            parser.feed(data)

        msg = parser.close()
        digest = pyzor.digest.DataDigester(msg).value
        check = pyzor.client.Client().check(digest)

        d = {k: v for k, v in check.items()}
        j = json.dumps(d) + "\n"
        self.request.sendall(j.encode("utf-8"))


class Server(ThreadingMixIn, UnixStreamServer):
    pass


def main():
    addr = "./sock"

    try:
        os.remove(addr)
    except OSError:
        if os.path.exists(addr):
            raise

    srv = Server(addr, RequestHandler)
    try:
        srv.serve_forever()
    finally:
        srv.server_close()


if __name__ == "__main__":
    main()
