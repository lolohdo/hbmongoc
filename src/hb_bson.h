//
//  hb_bson.h
//  hbmongoc
//
//  Created by Teo Fonrouge on 8/26/17.
//  Copyright © 2017 Teo Fonrouge. All rights reserved.
//

#ifndef hb_bson_h
#define hb_bson_h

#include <stdio.h>
#include <bson.h>

typedef enum { _hb_bson_t_ } hbbson_t_;

typedef struct _HB_BSON_
{
    hbbson_t_ type_t;
    bson_t * bson;
    int documentLevel;
} HB_BSON, * PHB_BSON;

bson_t *    bson_param( int iParam, int type );
PHB_BSON    hbbson_param( int iParam );
PHB_BSON    hbbson_new_dataContainer( hbbson_t_ type, void * p );

#endif /* hb_bson_h */