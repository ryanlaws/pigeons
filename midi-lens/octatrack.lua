return {
    -- idk if long name will be used
    ['long-name']="Elektron Octatrack",

    -- probably nice as a prefix
    ['short-name']="OT",

    -- the implication is that this will be put in an environment.
    -- but there are architectural issues with that at the moment.
    -- so this is mostly aspirational.
    ['config']={
        ['default-channel']=9 -- auto channel
    },

    -- this syntax feels a bit tedious to me.
    -- nesting would be cool - good for editing on norns' screen.
    -- so would a "note" helper to replace type=note.
    -- and I think range/offset could be optimized but idk how.
    -- also modal aliases would be cool.
    -- for example, the track fx could instead be delay-specific.
    ['messages']={
        ['trig-audio-track']=
            {['type']='note', ['n']={['range']={1,8}, ['offset']=23}},
        ['trig-sample']=          
            {['type']='note', ['n']={['range']={1,8}, ['offset']=35}},
        ['trig-midi-track']=      
            {['type']='note', ['n']={['range']={1,8}, ['offset']=47}},
        ['trig-chromatic']=       
            {['type']='note', ['n']={['range']={-12,12}, ['offset']=84}},

        ['stop-seq']=
            {['type']='note', ['n']=33},
        ['start-seq']=
            {['type']='note', ['n']=34},
        ['restart-seq']=
            {['type']='note', ['n']=35},
        ['rec-combo']=
            {['type']='note', ['n']=60},
        ['rec-ab']=
            {['type']='note', ['n']=61},
        ['rec-cd']=
            {['type']='note', ['n']=62},
        ['rec-src3']=
            {['type']='note', ['n']=63},
        ['pickup-playstop']=
            {['type']='note', ['n']=64},
        ['multiply']=
            {['type']='note', ['n']=65},
        ['mute']=
            {['type']='note', ['n']=66},
        ['cue']=
            {['type']='note', ['n']=67},
        ['track-next']=
            {['type']='note', ['n']=68},
        ['track-previous']=
            {['type']='note', ['n']=69},
        ['toggle-seq-sync']=
            {['type']='note', ['n']=70},
        ['toggle-seq-syncstart']=
            {['type']='note', ['n']=71},

        ['audio-level']=
            {['type']='cc', ['n']=07},
        ['audio-balance']=
            {['type']='cc', ['n']=08},

        ['audio-level2']=   -- is this different from 7?
            {['type']='cc', ['n']=46},
        ['audio-cuelevel']=
            {['type']='cc', ['n']=47},
        ['audio-crossfader']=
            {['type']='cc', ['n']=48},
        ['audio-cue']=
            {['type']='cc', ['n']=51, ['v']={['range']={0,1}}},
        ['audio-arm-play']=
            {['type']='cc', ['n']=52, ['v']={['range']={0,1}}},
        ['audio-arm-record']=
            {['type']='cc', ['n']=53, ['v']={['range']={0,1}}},
        ['audio-arm-all']=
            {['type']='cc', ['n']=54, ['v']={['range']={0,1}}},
        ['audio-arm-all']=
            {['type']='cc', ['n']=54, ['v']={['range']={0,1}}},
        ['audio-pickup-ab-level']=
            {['type']='cc', ['n']=57},
        ['audio-pickup-cd-level']=
            {['type']='cc', ['n']=58},
        ['audio-note-on']=
            {['type']='cc', ['n']=59},
        ['audio-note-off']=
            {['type']='cc', ['n']=60},

        ['track-playparam']=
            {['type']='cc', ['n']={['range']={1,6}, ['offset']=15}},
        ['track-ampparam']=
            {['type']='cc', ['n']={['range']={1,6}, ['offset']=21}},
        ['track-lfo-speed']=
            {['type']='cc', ['n']={['range']={1,3}, ['offset']=27}},
        ['track-lfo-depth']=
            {['type']='cc', ['n']={['range']={1,3}, ['offset']=30}},
        ['track-fx1']=
            {['type']='cc', ['n']={['range']={1,6}, ['offset']=33}},
        ['track-fx2']=
            {['type']='cc', ['n']={['range']={1,6}, ['offset']=39}},
        ['track-mute']=
            {['type']='cc', ['n']=49, ['v']={['range']={0,1}}},
        ['track-solo']=
            {['type']='cc', ['n']=50, ['v']={['range']={0,1}}},

        ['scene-a']=
            {['type']='cc', ['n']=55},
        ['scene-b']=
            {['type']='cc', ['n']=56},

        ['fetch-audio-params']=
            {['type']='cc', ['n']=61, ['v']=0},

        ['midi-mute']=
            {['type']='cc', 
                ['n']={['name']='track',['range']={1,8},['offset']=111}, 
                ['v']={['name']='muted',['range']={0,1}}},
        ['midi-solo']=
            {['type']='cc', 
                ['n']={['name']='track',['range']={1,8},['offset']=119}, 
                ['v']={['name']='soloed',['range']={0,1}}},
    }
}