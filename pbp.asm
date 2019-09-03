OEMname:            db      "MYBOOT  "
    bytesPerSector:     dw       512
    sectPerCluster:     db       1
    reservedSectors:    dw       1
    numFAT:             db       2
    numRootDirEntries:  dw       240
    numSectors:         dw       5760
    mediaType:          db       0xf0
    numFATsectors:      dw       9
    sectorsPerTrack:    dw       36
    numHeads:           dw       2
    numHiddenSectors:   dd       0
    numSectorsHuge:     dd       0
    driveNum:           db       0
    reserved:           db       0x00
    signature:          db       0x29
    volumeID:           dd       0x54428E71
    volumeLabel:        db      "NO NAME    "
    fileSysType:        db      "FAT12   "