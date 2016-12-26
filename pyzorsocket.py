import argparse
import email.parser
import email.policy
import os
import json
from socketserver import UnixStreamServer, ThreadingMixIn, StreamRequestHandler

import pyzor.client
import pyzor.digest


class RequestHandler(StreamRequestHandler):

    def handle(self):
        cmd = self.rfile.readline().decode()[:-1]
        if cmd == "CHECK":
            self.handle_check()
        else:
            self.write_json({"error": "unknown command"})

    def handle_check(self):
        parser = email.parser.BytesParser(policy=email.policy.SMTP)
        msg = parser.parse(self.rfile)

        digest = pyzor.digest.DataDigester(msg).value
        check = pyzor.client.Client().check(digest)

        self.write_json({k: v for k, v in check.items()})

    def write_json(self, d):
        j = json.dumps(d) + "\n"
        self.wfile.write(j.encode())


class Server(ThreadingMixIn, UnixStreamServer):
    pass


def rm(path):
    """Remove file at path. Ignores error if file does not exist."""
    try:
        os.remove(path)
    except OSError:
        if os.path.exists(path):
            raise


def main():
    argp = argparse.ArgumentParser(description="Expose pyzor on a socket")
    argp.add_argument("addr", help="path to open unix socket at")
    args = argp.parse_args()

    rm(args.addr)

    srv = Server(args.addr, RequestHandler)
    try:
        srv.serve_forever()
    finally:
        srv.server_close()
        rm(args.addr)


if __name__ == "__main__":
    main()
