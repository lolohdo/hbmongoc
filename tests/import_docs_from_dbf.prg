/*
 * import dbf example
 */

#include "hbmongoc.ch"
#include "dbstruct.ch"

#define db_name     "hbmongoc"
#define coll_name   "test.dbf"

PROCEDURE main()
    LOCAL client
    LOCAL collection
    LOCAL millis
    LOCAL filter

    /* REQUIRED to initialize mongoc internals */
    mongoc_init()

    CLS

    WAIT "press any key to start..."

    USE test

    IF neterr()
        QUIT
    ENDIF

    client := mongoc_client_new( "mongodb://localhost" )
    collection := mongoc_client_get_collection( client, db_name, coll_name )

    /* drops collection (if exists) */
    mongoc_collection_drop( collection, coll_name )

    millis := hb_milliSeconds()
    importDocs( collection )

    ? hb_nToS( TEST->( recCount() ) ), "records imported in", hb_nToS( hb_milliSeconds() - millis ), "milliseconds"

    WAIT

    WAIT "press any key to show ALL docs in collection..."

    filter := bson_new()
    displayDocs( collection, filter )

    WAIT

    WAIT "press any key to show only docs with 'John' as NAME in collection..."

    filter := bson_new()
    BSON_APPEND_UTF8( filter, "FIRST", "John" )

    displayDocs( collection, filter )

    WAIT "press any key to exit..."

    /* REQUIRED to cleanup mongoc internals */
    mongoc_cleanup()

RETURN

STATIC PROCEDURE displayDocs( collection, filter )
    LOCAL opts
    LOCAL cursor
    LOCAL doc

    opts := bson_new()

    cursor := mongoc_collection_find_with_opts( collection, filter, opts )

    WHILE mongoc_cursor_next( cursor, @doc )
        ? bson_as_json( doc )
    ENDDO

RETURN

STATIC PROCEDURE importDocs( collection )
    LOCAL dbfStruct
    LOCAL itm
    LOCAL doc
    LOCAL error
    LOCAL recNo

    dbfStruct := dbStruct()

    recNo := 1
    TEST->(dbGoTo( 1 ) )

    WHILE ! TEST->( eof() )

        doc := bson_new()

        BSON_APPEND_INT32( doc, "_id", recNo )  /* using dbf recNo() as doc _id */

        FOR EACH itm IN dbfStruct
            SWITCH itm[ DBS_TYPE ]
            CASE "C"
                BSON_APPEND_UTF8( doc, itm[ DBS_NAME ], rTrim( fieldGet( itm:__enumIndex ) ) )
                EXIT
            CASE "D"
                BSON_APPEND_DATE_TIME( doc, itm[ DBS_NAME ], hb_dToT( fieldGet( itm:__enumIndex ) ) ) /* date type is converted to dateTime */
                EXIT
            CASE "L"
                BSON_APPEND_BOOL( doc, itm[ DBS_NAME ], fieldGet( itm:__enumIndex ) )
                EXIT
            CASE "N"
                BSON_APPEND_DOUBLE( doc, itm[ DBS_NAME ], fieldGet( itm:__enumIndex ) )
                EXIT
            OTHERWISE
                BSON_APPEND_NULL( doc, itm[ DBS_NAME ] )
            ENDSWITCH
        NEXT

        IF ! mongoc_collection_insert( collection, MONGOC_INSERT_NONE, doc, nil, @error )
            ? "Insert error:", HBBSON_ERROR_MESSAGE( error )
        ENDIF

        TEST->( dbGoto( ++recNo ) )

    ENDDO

RETURN
