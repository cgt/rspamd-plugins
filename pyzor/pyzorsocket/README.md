# pyzorsocket

pyzorsocket exposes [pyzor](https://github.com/SpamExperts/pyzor) on a socket.

## Protocol
The protocol is very simple. The client sends a command in all-caps
followed by a newline (`\n`). The command corresponds to a pyzor command
such as `check`. The client then sends the entire e-mail to be checked,
just as when piping to the `pyzor` command. After all data has been
sent, the client must close its socket for writing.

The server hands off the e-mail to pyzor. Whatever pyzor responds with is
serialized as JSON and sent back to the client. The connection is then closed.

### Example

A client wants to check an e-mail with pyzor. With the `pyzor` command
this is done by piping a mail to `pyzor check`. The example with pyzorsocket 
below is equivalent, except that the response is serialized as JSON.

All newline characters in data shown escaped.
Actual newlines in example only included as a visual aid.

Client sends:

	CHECK\n
	From: John Doe <jdoe@machine.example>\r\n
	To: Mary Smith <mary@example.net>\r\n
	Subject: Saying Hello\r\n
	Date: Fri, 21 Nov 1997 09:55:06 -0600\r\n
	Message-ID: <1234@local.machine.example>\r\n\r\n

	This is a message just to say hello.\r\n
	So, "Hello".\r\n

The client closes its socket for writing, and the server replies:

	{"Thread": "16329", "Diag": "OK", "Count": "0", "Code": "200", "PV": "2.1", "WL-Count": "0"}\n

## License
Distributed under the MIT license. See top-level LICENSE file.

Note that this license does not apply to pyzor itself,
which is distributed under the GNU General Public License version 2.
