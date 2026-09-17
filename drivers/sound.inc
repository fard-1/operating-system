struc  AudioProcess     ptr=?,    size=?, isloop=?, vol=?    {
       .currentPtr      dd      ptr
       .oldPtr          dd      ptr
       .rewrites        dd      0
       .size            dd      size
       .copiedSize      dd      0
       .repeatSound     db      isloop
       .volume          dd      vol
}