




// this file defines  a process class, which is ONLY used by source nodes that have that have a URI of type:   "process" , e.g:      uri://process  "zombieTrig1"
// you can define any number of these process clases, each one, corresponding to a particular type of processing  behavoir you define

// this class is kamakazie instances, generated by the "trigger" call,  with only i-tome spatializer update

//  FOR USE WITH SYNTHDEFS that generate delayed random offsets for clones

// required:  set up class struct

~zombieTrig1= Environment[
	// required fields
	'nodeName' -> \nil,
	'nodeGroupName' -> \nil,
	'nodeGroup' -> \nil,


	// project specific
	//'cloneVector' -> [],  // vector to store allocated synths
	'debugFlag' -> 0,
	'synth' -> \zkarpluck3P,  // \zparticle2P,
	'kCount' -> 0,
	// other state
	'spread' -> 0,  // register used for kamikazi instantiation
	'pitchSeqGlobalMode' -> 0,
	'pitchSeqSym' -> \default,
	'pitchSeqLen' -> 1,   // not used
	'pitchSeqIncr' -> 1,   // used, but only to set global sequencer state
	'pitchSeqPos' -> 0,     // not used
	// playback state
	'transposition' -> 0,
	'synthCountMax' ->  200,    //this should be the value that would break the machine for the synthdef
];

// required: set these variables to the process name;
~processName = \zombieTrig1;
~process = ~zombieTrig1;
~process.know=true;


if (~satie4unity == nil, {
	error(~processName ++ ": ~satie4unity protocol undefined, can't register this process");
}, // else
{
	// if already registered, re-register
	if (  ~satie4unity.allProcesses.includesKey(~processName) == true,
		{
			inform("un-registering process: "++~processName);
			~satie4unity.allProcesses.removeAt(~processName);
	});

	inform("registering process: "++~processName);
	~satie4unity.allProcesses.put(~processName, ~process);


});


// set up class instance dictionary

~zombieTrig1_instances = Dictionary.new();

// define any custom "class"  variables, referenced by all "instants"  of "zombieTrig1" class
if (~zombieTrig1_pitchSequences == nil,
	{
		~zombieTrig1_pitchSequences = Dictionary.new();
		~zombieTrig1_pitchSequences.put(\default, Dictionary.new());
		~zombieTrig1_pitchSequences.at(\default).put(\pitches, [60]);
		~zombieTrig1_pitchSequences.at(\default).put(\pos, 0);
		~zombieTrig1_pitchSequences.at(\default).put(\incr,1);
		~zombieTrig1_pitchSequences.at(\default).put(\size,1);

});

// required functions

~zombieTrig1.cleanup = { | self |

	var synth;

	// add code here to manage project-specific stuff
	postf("~zombieTrig1.clearSynths: clearing synths in node: % group \n", self.nodeName);
	// var nodename=(self.nodeName++"_"++item).asSymbol;
	// ~scbr.cleanInstance(nodename.asSymbol, self.nodeGroupName);
	// });

	/*	if ( ~satie4unity.maxSynthCount == nil,
	{
	error("zombieTrig1.cleanup:   ~satie4unity.maxSynthCount is NIL but should already be defined ");
	},
	// else
	{ ~satie4unity.maxSynthCount = ~satie4unity.maxSynthCount - self.synthCountMax;
	});

	~satie4unity.maxSynthCount.postln;*/

	~zombieTrig1_instances.removeAt(self.nodeName);



};


// required function but adaptable to project specifics
// generates N synths
~zombieTrig1.setup = { | self, nodeName, nodeGroupName, argsList  |
	var thisGroup = ~scbr.satieGroups[nodeGroupName.asSymbol] ;

	self.nodeName = nodeName;
	self.nodeGroupName = nodeGroupName;
	self.nodeGroup = thisGroup;
	//'zombieTrig1,setup'.postln;


	//postf(" zombieTrig1.setup: node: %    args:   %    size:  %\n", nodeName, argsList, argsList.size);

	// project-specific parsing of args string (coming from setUri OSC message string)
	/*	if ( argsList.size >= 2,
	{
	//~sheefaVec = argvec;

	postf(" zombieTrig1.setup: node: %    args:   %    size:  %\n", nodeName, argsList, argsList.size);

	if ( argsList[0].asString == "readPitches",
	{
	self.readPitches(argsList[1]);
	postf(" zombieTrig1.setup: node: %   calling readPitches with % \n", nodeName, argsList[1]);
	},
	// else bad arg
	{
	error("zombieTrig1.setup: unrecognized key, expecting 'readPitches' ");
	});
	},
	// esle missing readFile e
	{
	error("zombieTrig1.setup:  incomplete setup message, expecting 'readPitches  /filepath/file'  ");

	});
	*/

	self[\properties] =  Dictionary.new();  // set up state register for synthfef properties

	~zombieTrig1_instances.put(self.nodeName.asSymbol, self);

	~satie4unity.allProcesses.put(~processName, ~process);

	/*	if ( ~satie4unity.maxSynthCount == nil,
	{
	~satie4unity.maxSynthCount = self.synthCountMax;
	},
	// else
	{
	~satie4unity.maxSynthCount = ~satie4unity.maxSynthCount + self.synthCountMax;
	});

	~satie4unity.maxSynthCount.postln;*/
};


// end of required class functions

// end of required class functions


// the functions below are not requied
// however if defined, they will be called by satie4unity


// if defined, will be called when node's "update" message is received
// otherwise satie4unity will send the  "update" message to the node's group
~zombieTrig1.updateConnection = { | self, aziDeg, eleDeg, gainDB, delayMs, lpHz, distance |

	// do nothing for this node, since spatialization is done using the trigger method
};

// if defined, will be called when node's "spread" message is received
// otherwise the "spread" message will be applided to the node's group
~zombieTrig1.spread = { | self, spreadVal |

	self.spread = spreadVal;
	//postf("spread message:  val:% \n", spreadVal);
};


// if defined, will be called when node's "prop" message is received
// otherwise the "prop" message will be applided to the node's group
~zombieTrig1.prop = { | self, key, value |

	self[\properties].put(key, value);  // keep property state for initializing synthdefs

	if ( (self.debugFlag != 0),{
		postf("node: %  prop message: key: %    val:% \n", self.nodeName, key, value);
	});


	// postf("prop message: key: %    val:% \n", key, value);
};


// totally custom functions.  Calls to these functions result from OSC events received by satie4unity from Unity, and then applied to these functions,  if they exist

~zombieTrig1.setIncrement = { arg self, items = #[1] ;

	if ( items.size != 1,
		{
			warn("~zombieTrig1.setIncrement: node:"++self.nodeName++":  bad item count,  takes one float arg, received: "++items.size++"  items:  ");
			items.postln;
		},
		//else
		{
			//postf("zombieTrig1.setIncrement:  increment = % \n", items[0].asFloat);

			if (self.pitchSeqGlobalMode != 0,
				{
					~zombieTrig1_pitchSequences.at(self.pitchSeqSym).put(\incr, items[0].asFloat);
				},
				// else
				{
					self.pitchSeqIncr = items[0].asFloat;
			});
	});
};


// custom method
// called with args:  // list: force, impactIncidence, aziDeg, eleDeg, gainDB, delayMs, lpHz, hpHz , distance
~zombieTrig1.trigger = { arg self, items = #[1,2,3,4,5,6,7,8,9] ;
	var thisGroup = self.nodeGroup;
	var seqName, pitch, position, incr, size, force, incidence;
	var aziDeg, eleDeg, gainDB, delayMs, lpHz, hpHz, distance;
	var xzDist, yDist, aziScaler, elevScaler;
	var cloneParams;

	if ( items.size != 9,
		{
			postf("~zombieTrig1.trigger:  bad item count, expecing '[ pitch force incidence]' , received: % items\n",items.size);
		},
		{ // else

			if (s.numSynths > (self.synthCountMax),
				{
					postf("%: ~zombieTrig1.trigger:  exceeding synthcount by: % items\n", self.nodeName, (s.numSynths - self.synthCountMax));
				},
				{ // else under voice limit, generate synth

					var nodename=(self.nodeName++"_"++self.kCount).asSymbol;
					var params;
					var synthParams;
					var synth;

					self.kCount= self.kCount + 1;


					// kind of stupid ti assert thus value t wat
					// NO GROUP TX  IN THIS CASE:   thisGroup.set(\randTrigMaxMs, self.triggerIntervalMs);
					// kamakazi must be fully parameterized at creation

					// items.postln;

					seqName = self.pitchSeqSym;
					force =  items[0].asFloat;
					incidence = items[1].asFloat.abs;   // not using negative values
					aziDeg = items[2].asFloat.raddeg;
					eleDeg = items[3].asFloat.raddeg;
					gainDB = items[4].asFloat;
					delayMs = items[5].asFloat;
					lpHz = items[6].asFloat;
					hpHz = items[7].asFloat;
					distance = items[8].asFloat;


					size = ~zombieTrig1_pitchSequences.at(seqName.asSymbol).at(\size);

					params = [
						\randTrigMaxMs, self.triggerIntervalMs, \aziDeg, aziDeg, \eleDeg, eleDeg, \gainDB, gainDB,
						\delayMs, delayMs, \lpHz , lpHz, \hpHz, hpHz,\spread, self.spread
					];

					if ( self[\properties] != nil, { synthParams = params++ self[\properties].getPairs;}); // combine param arrays

					if (self.pitchSeqGlobalMode != 0,
						{

							position = ~zombieTrig1_pitchSequences.at(seqName.asSymbol).at(\pos);
							incr = ~zombieTrig1_pitchSequences.at(seqName.asSymbol).at(\incr);
							pitch = ~zombieTrig1_pitchSequences.at(seqName.asSymbol).at(\pitches)[position];
							~zombieTrig1_pitchSequences.at(seqName.asSymbol).put(\pos,  ((position + incr) % size) );
						},
						// else   instance specific read
						{
							position = self.pitchSeqPos;
							incr = self.pitchSeqIncr;
							pitch = ~zombieTrig1_pitchSequences.at(seqName.asSymbol).at(\pitches)[position];
							self.pitchSeqPos = ((position + incr) % size);
					});

					cloneParams = synthParams++ [ \note, [ pitch+self.transposition, force, incidence ], \t_trig, 1 ];

					//[ \note, [ pitch+self.transposition, force, incidence ]].postln;

					//postf("zombieTrig1:trigger(): synthdefname: "++ self.synth.asSymbol++[ pitch+self.transposition, force, incidence ]++" \n");
					//postf("zombieTrig1:trigger(): synthdefname: "++ cloneParams++" \n");

					synth = ~scbr.makeKamikaze(nodename, self.synth.asSymbol, self.nodeGroupName, cloneParams);
					// synth.set(\note, [ pitch+self.transposition, force, incidence ], \t_trig, 1);
			});
	});
};

// custom method
~zombieTrig1.readPitches = { arg self, items = #["/tmp"] ;

	var pitchList, seqName, file, csvmidifilePath;

	//postf("readPitches:   arg 0: % \n",  items[0] );

	if ( items.size != 1,
		{
			warn("~zombieTrig1.readPitches:  bad item count, expecting one filePath arg, received: % items\n",items.size);
		},
		//else
		{
			csvmidifilePath = items[0].asString;

			if (self.debugFlag != 0,
				{
					postf("%: ~zombieTrig1.readPitches: ARG:  %  \n", self.nodeName,csvmidifilePath);
			});

			seqName = csvmidifilePath.split.last;


			// process only if pitch sequence has not yet been loaded
			if ( ~zombieTrig1_pitchSequences.includesKey(seqName.asSymbol),
				{

					//  file already loaded, just set instance  specific state
					postf("zombieTrig1.readPitches:  sequence % already loaded, skipping file load\n", seqName);
					self.pitchSeqSym = seqName.asSymbol;
					self.pitchSeqLen = ~zombieTrig1_pitchSequences.at(seqName.asSymbol).at(\size);
					// self.pitchSeqPos = 0;    DONT RESET READ HEAD

					// and reset sequence's global state  BUT DO NOT RESET READ HEAD
					// ~zombieTrig1_pitchSequences.at(seqName.asSymbol).put(\pos, 0);
					~zombieTrig1_pitchSequences.at(seqName.asSymbol).put(\incr, self.pitchSeqIncr);   // using instance specific state.. may overwrite
				},
				{
					// else  try to read file and create pitch sequence

					pitchList = List.new();

					if (csvmidifilePath[0] != $/,
						{
							csvmidifilePath = ~satie4unity.projectDirectory++"/"++csvmidifilePath;
					});

					if (self.debugFlag != 0,
						{
							postf("%: ~zombieTrig1.readPitches:  try to open file:   % items\n", self.nodeName, csvmidifilePath);
					});

					file = File(csvmidifilePath.standardizePath,"rb");



					if  ( file.isOpen == false,
						{
							error("~zombieTrig1.readPitches: ***********************************");
							postf("%: ~zombieTrig1.readPitches:  could not open file: % \n", self.nodeName, csvmidifilePath);
						},
						//  else file found, try to parse

						{

							//postf("file % length:  %\n", csvmidifilePath, file.length);

							file.do({
								var value, event;

								value = file.getLine();

								if (value.contains("Note_on_c"),
									{
										event = value.split($,);
										pitchList.add(event[4].asInt);
								});
							});

							file.close;

							if (pitchList.size > 0,
								{
									postf("%: ~zombieTrig1.readPitches:  % pitches read from file %\n", self.nodeName, pitchList.size,  csvmidifilePath);
									// add sequence to dictionary

									~zombieTrig1_pitchSequences.removeAt(seqName.asSymbol);   // overwrite previous

									~zombieTrig1_pitchSequences.put(seqName.asSymbol, Dictionary.new());
									~zombieTrig1_pitchSequences.at(seqName.asSymbol).put(\pitches, pitchList);
									~zombieTrig1_pitchSequences.at(seqName.asSymbol).put(\size, pitchList.size);
									~zombieTrig1_pitchSequences.at(seqName.asSymbol).put(\pos, 0);
									~zombieTrig1_pitchSequences.at(seqName.asSymbol).put(\incr, 1);


									//~zombieTrig1_pitchSequences.removeAt(seqName.asSymbol);
									//~zombieTrig1_pitchSequences.put(seqName.asSymbol, pitchList);
									//~zombieTrig1_pitchSequences.put(seqName.asSymbol,

									// set instance local state -- currently not used, but available for future deployment
									self.pitchSeqSym = seqName.asSymbol;
									self.pitchSeqLen = pitchList.size;
									self.pitchSeqPos = 0;
								},
								//else
								{
									error("~zombieTrig1.readPitches: ***********************************");
									post(" \t % pitches read from file %\n", pitchList.size,  csvmidifilePath);
							});
					});
			});
	});

};

/*
testing

~myFile =  "/Users/zack/Dropbox/Unity3D/projects_unity5/balljamDemoSATIE_2015_unity5/Assets/StreamingAssets/midi/pitchSequences/bjGroove.mid.mid.txt";
~zombieTrig1.readPitches(~myFile);
~zombieTrig1.pitchSeqLen;
~zombieTrig1.pitchSeqName;

*/
