// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

(
~spatOSCMaker = {| port = 18032 |
	var oscPort = port;
	e = Environment.make({

		// main OSC method
		~newOSC = {|self, id, cb, path|
			var idsym = id.asSymbol;
			//postf("~newOSC id: % path: %\n",idsym,path);
			OSCdef(idsym, cb, path, recvPort: oscPort)
		};

		~deleteOSC = {|self, id|
			//postf("~deleteOSC  id: %\n",id.asSymbol);
			OSCdef(id.asSymbol ).clear.free;
		};

		// create all /core/source/*/ at once.
		~sourceOSC = {|self, sourceName, cb|
			self.newOSC(sourceName ++ \prop, cb,  "/spatosc/core/source" +/+ sourceName +/+ "/prop");
			self.newOSC(sourceName ++ \uri, cb,  "/spatosc/core/source" +/+ sourceName +/+ "/uri");
			self.newOSC(sourceName ++ \state, cb,  "/spatosc/core/source" +/+ sourceName +/+ "/state");
			self.newOSC(sourceName ++ \event, cb,  "/spatosc/core/source" +/+ sourceName +/+ "/event");
		};


		// create all /core/source/*/ at once.
		~groupOSC = {|self, groupName, cb|
			self.newOSC(groupName ++ \prop, cb,  "/spatosc/core/group" +/+ groupName +/+ "/prop");
			self.newOSC(groupName ++ \uri, cb,  "/spatosc/core/group" +/+ groupName +/+ "/uri");
			self.newOSC(groupName ++ \state, cb,  "/spatosc/core/group" +/+ groupName +/+ "/state");
			self.newOSC(groupName ++ \event, cb,  "/spatosc/core/group" +/+ groupName +/+ "/event");
			self.newOSC(groupName ++ \add, cb,  "/spatosc/core/group" +/+ groupName +/+ "/add");
			self.newOSC(groupName ++ \drop, cb,  "/spatosc/core/group" +/+ groupName +/+ "/drop");
		};

		// create connection hooks for connection messages
		// /spatosc/core/connection/sourceNode->listenerNode/update azi elev delayMS gainDB lpHZ
		// /spatosc/core/connection/sourceNode->listenerNode/spread  exp  // for incidence effect
		~connectionOSC = {|self, connectionName, cb|
			var path = "/spatosc/core/connection" +/+ connectionName;

			//path.postln;
			self.newOSC(connectionName ++ \update, cb,  path +/+ "update");
			self.newOSC(connectionName ++ \spread, cb,  path +/+ "spread");
			self.newOSC(connectionName ++ \hpHz, cb,  path +/+ "hpHz");
		};

		// try to remove the OSC definitions.
		~removeSourceOSC = {|self, sourceName|
			self.deleteOSC(sourceName ++ \prop);
			self.deleteOSC(sourceName ++ \uri);
			self.deleteOSC(sourceName ++ \state);
			self.deleteOSC(sourceName ++ \event);
		};

		// try to remove the OSC definitions.
		~removeGroupOSC = {|self, groupName|
			self.deleteOSC(groupName ++ \prop);
			self.deleteOSC(groupName ++ \uri);
			self.deleteOSC(groupName ++ \state);
			self.deleteOSC(groupName ++ \event);
			self.deleteOSC(groupName ++ \add);
			self.deleteOSC(groupName ++ \drop);
		};


		// try to remove the OSC definitions.
		~removeConnectionOSC = {|self, connectionName|

			//OSCdef((connectionName ++ \update).asSymbol ).clear.free;
			//OSCdef((connectionName ++ \spread).asSymbol ).clear.free;
			self.deleteOSC(connectionName ++ \update);
			self.deleteOSC(connectionName ++ \spread);
			self.deleteOSC(connectionName ++ \hpHz);
		};

				//  /a.renderer    for control messages to the renderer
		~basicRendererOSC = {|self, id, cb|
				//path.postln;
			self.newOSC(id, cb,  "/a.renderer");
		};
			// try to remove the OSC definitions.

		~removeBasicRendererOSC = {|self, id|
			self.deleteOSC(id);
		};



	});
	e.know = true;
	e;
};

//e.(\goo, {\gotIt.postln;}, "/goo");
/*
~spatOSC = ~spatOSCMaker.value();

~spatOSC.newOSC(\soo, {'ok'.postln;}, "/soo");
~spatOSC.removeOSC(\soo);
*/
)