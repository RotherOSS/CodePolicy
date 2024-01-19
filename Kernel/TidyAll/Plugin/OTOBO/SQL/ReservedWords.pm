# --
# OTOBO is a web-based ticketing system for service organisations.
# --
# Copyright (C) 2001-2020 OTRS AG, https://otrs.com/
# Copyright (C) 2019-2024 Rother OSS GmbH, https://otobo.de/
# --
# This program is free software: you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free Software
# Foundation, either version 3 of the License, or (at your option) any later version.
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <https://www.gnu.org/licenses/>.
# --

package TidyAll::Plugin::OTOBO::SQL::ReservedWords;

use strict;
use warnings;

use Moo;

extends qw(TidyAll::Plugin::OTOBO::Base);

sub validate_source {
    my ( $Self, $Code ) = @_;

    return if $Self->IsPluginDisabled( Code => $Code );

    my $TableCreate = 0;
    my $Counter;

    for my $Line ( split( /\n/, $Code ) ) {
        $Counter++;
        if ( $Line =~ /<Table/ ) {
            $TableCreate = 1;
        }
        if ( $TableCreate && $Line =~ /<Column.+?Name="(.+?)".*?\/>/i ) {
            if ( !$1 ) {
                return $Self->DieWithError(<<"EOF");
Found an empty column name!
Line $Counter: $Line
EOF
            }

            for my $ReservedWord (
                qw(
                    add all alter and
                    any as asc backup
                    begin between bigint binary
                    bit bottom break bulk by cache
                    call capability cascade case
                    cast char char_convert character
                    check checkpoint close comment
                    commit connect constraint contains
                    continue convert create cross
                    cube current current_timestamp current_user
                    cursor date dbspace deallocate
                    dec decimal declare default
                    delete deleting desc distinct
                    do double drop dynamic each
                    else elseif encrypted end
                    endif escape except exception
                    exec execute existing exists
                    externlogin fetch first float
                    for force foreign forward
                    from full goto grant
                    group having holdlock identified
                    if in index index_lparen
                    inner inout insensitive insert
                    inserting install instead int
                    integer integrated intersect into
                    iq is isolation join
                    key lateral left like
                    lock long match
                    membership message mode modify
                    natural new no noholdlock
                    not notify null numeric
                    of off on open
                    option options or order
                    others out outer over
                    passthrough precision prepare primary
                    print privileges proc procedure
                    publication raiserror readtext real
                    references release remote
                    remove rename reorganize resource
                    restore restrict return revoke
                    right role rollback rollup row rule save
                    savepoint scroll select sensitive
                    session set setuser share
                    smallint some sqlcode sqlstate
                    start stop subtrans subtransaction
                    synchronize syntax_error table temporary
                    then time timestamp tinyint
                    to top tran trigger
                    truncate tsequal unbounded undo union
                    unique unknown unsigned update
                    updating user using validate
                    values varbinary varchar variable
                    varying view wait waitfor
                    when where while window
                    with with_cube with_lparen with_rollup
                    within work writetext
                    NOMONITORING RECORDS_PER_BLOCK NOWAIT DYNAMIC_SAMPLING COLUMN_STATS GROUPS
                    NO_PX_JOIN_FILTER NO_STATS_GSETS SWAP_JOIN_INPUTS NOORDER TRIGGERS DEMAND
                    LOB GBY_CONC_ROLLUP ROWDEPENDENCIES NOSTRICT PRIVILEGE SEMIJOIN RAW USE_NL_WITH_INDEX
                    INFORMATIONAL DENSE_RANK NO_QUERY_TRANSFORMATION POINT TRACING NO_XML_QUERY_REWRITE
                    NOPARALLEL_INDEX LINK REF TIMEZONE_ABBR PIV_SSF TX READS DELAY BFILE PRIVATE MAXLOGMEMBERS
                    USE_SEMI COST EVALNAME NO_CARTESIAN TABNO TRACE PLAN HINTSET_END CONTAINER ADMIN COLUMN
                    SYSTEM TZ_OFFSET NLS_LENGTH_SEMANTICS DICTIONARY SCN_ASCENDING FIC_CIV NOOVERRIDE INDICATOR
                    BINARY_FLOAT_NAN ROWID SESSION_CACHED_CURSORS OBJNO SQL_TRACE BLOB RELATIONAL BIGFILE
                    AVAILABILITY GUARD GROUP_BY ADVISE MERGE QUOTA CFILE MEMBER THAN SALT DUMP EXTERNALLY
                    BOTH GUARANTEED EXTENT SECURITY SCALE SYS_DL_CURSOR TYPE DEREF_NO_REWRITE AUTO ESTIMATE
                    POWER USE_STORED_OUTLINES SID VARRAY LESS VALUE XMLFOREST MAXLOGHISTORY STORE REDUNDANCY
                    DEQUEUE DBA MATCHED PRESENT CPU_PER_CALL DEFINER UPD_JOININDEX NESTED_TABLE_SET_REFS
                    EXPAND_GSET_TO_UNION INDEX_SS_ASC EXTRACT ORDERED_PREDICATES ALIAS NO_USE_HASH PRIOR
                    X_DYN_PRUNE COMPOSITE_LIMIT OBJNO_REUSE REVERSE DISABLE CURRENT_DATE INITIAL MINIMUM
                    INTERMEDIATE PARTITION_LIST BYTE MOUNT PREBUILT SOURCE MODEL_PBY BITMAP_TREE LOGFILE
                    ROLES DEGREE INVALIDATE TABLESPACE PASSWORD_VERIFY_FUNCTION COLUMNS CHOOSE SMALLFILE LEVEL
                    OLD_PUSH_PRED DYNAMIC_SAMPLING_EST_CDN NLS_DATE_LANGUAGE SERVERERROR NESTED_TABLE_FAST_INSERT
                    STREAMS NL_SJ ELIMINATE_OUTER_JOIN ENTERPRISE DISASSOCIATE GROUPING PACKAGE DATE_MODE CHILD
                    NO_PRUNE_GSETS REJECT NORESETLOGS NO_CONNECT_BY_COST_BASED CHUNK OID RETENTION MAXTRANS
                    FBTSCAN NONE PARAMETERS ONLINE OUT_OF_LINE GLOBAL_NAME SPACE HINTSET_BEGIN PASSWORD_GRACE_TIME
                    NOCACHE FINAL YEAR RBA ERRORS CLASS USE_NL CONNECT_BY_COST_BASED BINARY_DOUBLE DEFINED
                    EVALUATION PURGE HOUR LENGTH PRECEDING DECREMENT SUBMULTISET INDEX_ROWS SCHEDULER
                    AUTHENTICATION NUMBER OIDINDEX OPAQUE SAMPLE UPDATABLE ORA_ROWSCN INTERPRETED
                    MATERIALIZED INDEX_COMBINE OPAQUE_XCANONICAL INLINE_XMLTYPE_NT RETURNING QUERY
                    OPT_ESTIMATE CLOB NO_EXPAND DETACHED PASSWORD_LOCK_TIME VECTOR_READ DATAFILE REPLACE
                    NLS_CHARACTERSET NO_ELIMINATE_JOIN BROADCAST CIV_GB HASH QB_NAME AFTER SYSDBA ACCOUNT
                    SEVERE PRECOMPUTE_SUBQUERY FUNCTION INDEXTYPES FLOB MULTISET NLS_SPECIAL_CHARS SKIP
                    IGNORE_OPTIM_EMBEDDED_HINTS INDEX_SS NOGUARANTEE LOCALTIMESTAMP DBA_RECYCLEBIN FILE THROUGH
                    PLSQL_WARNINGS MANAGE DRIVING_SITE FAILED SCAN_INSTANCES COMPLETE HIGH TRANSITIONAL
                    NO_SEMIJOIN DAY NOPARALLEL XMLATTRIBUTES MOVE NATIONAL REQUIRED SKIP_EXT_OPTIMIZER
                    NOREPAIR REBUILD JOB SEED POLICY USERS TOPLEVEL BITMAP DATAFILES HASH_AJ INITRANS
                    BLOCKSIZE FAST MINIMIZE SESSIONTZNAME SESSIONS_PER_USER SYS_OP_BITVEC NO_ELIMINATE_OBY
                    UBA DATA SUBPARTITION_REL SETS PRIVATE_SGA BINARY_FLOAT ENFORCED TABLE_STATS FLAGGER
                    TEMP_TABLE ARCHIVE NO_PUSH_SUBQ RECYCLE DATAOBJNO QUEUE_ROWP SQL CHAINED EMPTY
                    SAVE_AS_INTERVALS BITMAPS OPTIMIZER_FEATURES_ENABLE FUNCTIONS AUTOMATIC SECOND
                    NO_FILTERING NAMED SUSPEND LIKEC NO_BUFFER PQ_NOMAP NLS_LANG ADVISOR
                    FRESH NO_CONNECT_BY_FILTERING NOSORT PASSWORD HASHKEYS EXCLUDING INDEX_RRS DISK
                    BITS CACHE_CB USE STAR CURSOR_SPECIFIC_SEGMENT SB4 DISTRIBUTED HEAP MINEXTENTS DML
                    ATTRIBUTES NORELY KEYSIZE LEADING XMLCOLATTVAL FREELIST FAILED_LOGIN_ATTEMPTS
                    SHARED_POOL USE_ANTI BYPASS_RECURSIVE_CHECK ANTIJOIN ABORT INDEX_FILTER ROLLING
                    ITERATION_NUMBER COALESCE NO_SQL_TUNE CLUSTER PROTECTED PARTITION_HASH ERROR
                    NO_MULTIMV_REWRITE UB2 THREAD SINGLE SYS_PARALLEL_TXN INDEX_ASC PARTITION
                    DISMOUNT HIERARCHY STRIP NLS_DATE_FORMAT CORRUPTION STORAGE COMMITTED RECYCLEBIN
                    PARITY CACHE_TEMP_TABLE ENCRYPTION LOCALTIME REWRITE_OR_ERROR DBMS_STATS CHAR_CS
                    EXCEPTIONS EXPIRE AUDIT LDAP_REG_SYNC_INTERVAL NOMINVALUE LIBRARY COMPILE MAXVALUE
                    NAN NOSEGMENT NOLOGGING NOROWDEPENDENCIES PATH NOFORCE FINISH FIC_PIV MAX SYSAUX
                    DIMENSION ORGANIZATION NOSWITCH WRITE MINUS KILL OFFLINE TRANSACTION FACT BECOME
                    UNBOUND TIV_SSF OLD TEMPFILE EXPLOSION REFRESH MIRROR REF_CASCADE_CURSOR
                    OPCODE OVERFLOW CURSOR_SHARING_EXACT PUSH_SUBQ CARDINALITY USE_PRIVATE_OUTLINES
                    LIKE4 TYPES NOTHING TIMEZONE_HOUR UNQUIESCE RESIZE COLLECT INSTANCE SETTINGS EXPORT
                    DOMAIN_INDEX_NO_SORT MERGE_SJ LIMIT SYS_OP_EXTRACT LIKE2 STANDALONE LAST
                    CONNECT_BY_FILTERING RESTRICT_ALL_REF_CONS MERGE_CONST_ON UNIFORM SCAN WITHOUT
                    CPU_PER_SESSION PROGRAM SEG_FILE APPLY PASSWORD_LIFE_TIME DML_UPDATE ALLOW
                    SKIP_UNQ_UNUSABLE_IDX NO_MERGE CLOSE_CACHED_OPEN_CURSORS NESTED_TABLE_GET_REFS
                    SPECIFICATION CONSISTENT USE_CONCAT SYS_OP_NTCIMG$ PQ_MAP SHUTDOWN DEFERRABLE
                    FOLLOWING SPLIT UNPROTECTED TIME_ZONE SHRINK INDEX_SKIP_SCAN LOGICAL
                    MODEL_MIN_ANALYSIS XMLROOT SD_SHOW CREATE_STORED_OUTLINES RAPIDLY USE_MERGE QUEUE_CURR
                    STRICT MV_MERGE NO_ORDER_ROLLUPS TREAT UNLIMITED TUNING CHANGE PCTUSED MOVEMENT
                    NO_REWRITE ANCILLARY CLUSTERING_FACTOR BLOCK_RANGE SEQUENTIAL GLOBALLY XMLTYPE INTERVAL
                    SEQUENCED SWITCHOVER AT NOMAXVALUE SYS_FBT_INSDEL KERBEROS TIMEZONE_OFFSET
                    INDEX_SS_DESC RECOVERY NLS_TERRITORY SIZE FAILGROUP ELEMENT INSTANCES DIRECTORY
                    IDGENERATORS PRESERVE_OID NO_PARALLEL SUBPARTITIONS EXEMPT INDEX_JOIN BEGIN_OUTLINE_DATA
                    NETWORK LOCAL UNUSED NOAUDIT PHYSICAL WRAPPED FREEPOOLS PCTINCREASE FILTER
                    GATHER_PLAN_STATISTICS SYSOPER SD_INHIBIT SEGMENT DISABLE_RPKE NLS_SORT PATHS
                    ENTRY LDAP_REGISTRATION_ENABLED DISKS OBJECT INCREMENTAL REGEXP_LIKE OVERFLOW_NOMOVE
                    SUBQUERIES NO_PARALLEL_INDEX XID INITIALIZED STATISTICS ENCRYPT AUTOALLOCATE TEMPLATE
                    LDAP_REGISTRATION NO_UNNEST NO_PARTIAL_COMMIT ORDINALITY NLS_COMP NOCOMPRESS RULES
                    IMMEDIATE MAIN REFERENCING ENQUEUE SEG_BLOCK UNRECOVERABLE NO_MONITORING NO_ACCESS
                    RESOLVER TIMEZONE_MINUTE NO_ELIMINATE_OUTER_JOIN NO_INDEX UNNEST GUARANTEE BEHALF
                    ALWAYS TEST PERMANENT REGISTER CONFORMING SYNONYM SKIP_UNUSABLE_INDEXES USE_HASH
                    OPERATOR NO_PULL_PRED USE_TTT_FOR_GSETS SERIALIZABLE MIGRATE ITERATE PLSQL_CCFLAGS
                    IGNORE_WHERE_CLAUSE CPU_COSTING TRAILING LOCAL_INDEXES OVERLAPS EXTENDS NOAPPEND
                    METHOD REWRITE UNPACKED COLUMN_VALUE DATABASE EXCHANGE NO_TEMP_TABLE UPSERT YES
                    REBALANCE CONTEXT SPFILE NESTED TRACKING RESOLVE PFILE MAXDATAFILES GLOBAL
                    AUTHENTICATED NESTED_TABLE_ID INDEXES XMLNAMESPACES NO_REF_CASCADE SYSDATE OR_EXPAND
                    ASSOCIATE MODEL_COMPILE_SUBQUERY INITIALLY PARTIALLY XMLSCHEMA MINVALUE PIV_GB HEADER
                    RESTORE_AS_INTERVALS MANAGED BLOCK SINGLETASK DETERMINES PCTVERSION EXPLAIN AND_EQUAL
                    CLONE NO_USE_HASH_AGGREGATION BUFFER_CACHE XMLTABLE EXTERNAL NEVER IDENTIFIER PULL_PRED
                    INDEXED LOGICAL_READS_PER_CALL STARTUP FREELISTS UPD_INDEXES MATERIALIZE LOGON SCHEMA
                    NO_INDEX_SS NO_BASETABLE_MULTIMV_REWRITE IN_MEMORY_METADATA STRUCTURE MAXEXTENTS
                    RECOVERABLE REFERENCED NO_SET_TO_JOIN STAR_TRANSFORMATION CONNECT_BY_ISCYCLE ROWNUM
                    SNAPSHOT EXCLUSIVE CURRENT_TIME KEEP PASSWORD_REUSE_MAX WHENEVER INTERNAL_USE PX_JOIN_FILTER
                    PQ_DISTRIBUTE INLINE HWM_BROKERED FIRST_ROWS MODEL_NO_ANALYSIS NO_PUSH_PRED MODEL_PUSH_REF
                    COMPRESS NOREVERSE NO_INDEX_FFS GENERATED NATIVE LIKE_EXPAND RELY PACKAGES READ IGNORE
                    SQLLDR DISKGROUP FLUSH BYPASS_UJVC RESETLOGS SYS_OP_NOEXPAND PROTECTION BEFORE
                    INSTANTIABLE XMLELEMENT SUBPARTITION XMLPARSE FALSE ADMINISTER SELECTIVITY PCTTHRESHOLD
                    NEXT ERROR_ON_OVERLAP_TIME REKEY QUIESCE PX_GRANULE LOGOFF SCOPE BINDING NLS_CURRENCY
                    THE XMLPI PASSWORD_REUSE_TIME XMLQUERY PARTITIONS NO_QKN_BUFF MODEL_DYNAMIC_SUBQUERY
                    LOCATOR NLS_NCHAR_CONV_EXCP NO_STAR_TRANSFORMATION NOREWRITE TABLESPACE_NO ADMINISTRATOR
                    SEMIJOIN_DRIVER INDEX_FFS REDUCED KEYS LOCKED BUFFER VALIDATION FLASHBACK END_OUTLINE_DATA
                    TO_CHAR MASTER SYS_RID_ORDER PUBLIC MINUS_NULL NVARCHAR2 BOUND RBO_OUTLINE ACTIVATE VARCHAR2
                    MAXSIZE DECRYPT UID MLSLABEL UNTIL AUTOEXTEND ELIMINATE_JOIN RANDOM SEQUENCE NAV CONTENTS
                    USAGE ONLY REUSE MANUAL DOCUMENT CONNECT_BY_ISLEAF CONSIDER ENFORCE REMOTE_MAPPED
                    LIST MAXARCHLOGS ROW_LENGTH NULLS SHARED WELLFORMED INCLUDING APPEND FORCE_XML_QUERY_REWRITE
                    ISOLATION_LEVEL ACCESSED NLS_ISO_CURRENCY SUCCESSFUL CURRENT_SCHEMA ROWS DANGLING TRUE ZONE
                    NLS_NUMERIC_CHARACTERS DEBUG UPDATED RESTRICTED NO_EXPAND_GSET_TO_UNION STATEMENT_ID
                    NOCPU_COSTING AUTHORIZATION NO_USE_MERGE OPAQUE_TRANSFORM ARRAY MEASURES MODEL
                    CONNECT_TIME OPTIMIZER_GOAL SUPPLEMENTAL PCTFREE ANALYZE RECOVER DB_ROLE_CHANGE
                    BLOCKS MAXINSTANCES DDL NOVALIDATE PRESERVE OPT_PARAM CLEAR COARSE IDLE_TIME WALLET
                    SCALE_ROWS ARCHIVELOG CERTIFICATE NORMAL NO_MODEL_PUSH_REF TABLES UPGRADE INFINITE
                    NOARCHIVELOG CONTROLFILE IDENTITY PERFORMANCE INSTANTLY MAPPING ENABLE
                    LOGICAL_READS_PER_SESSION USE_HASH_AGGREGATION DEFERRED REPAIR NO_SWAP_JOIN_INPUTS
                    GLOBAL_TOPIC_ENABLED ELIMINATE_OBY SUBSTITUTABLE STANDBY NLS_CALENDAR LAYER BATCH KEY_LENGTH
                    INCREMENT BUILD ORDERED MONTH NCLOB EXPR_CORR_CHECK MEMORY UROWID EVENTS ALL_ROWS
                    SYS_OP_ENFORCE_NOT_NULL$ SD_ALL COMPUTE USE_WEAK_NAME_RESL NOMINIMIZE SPREADSHEET
                    NL_AJ BUFFER_POOL MERGE_AJ SIBLINGS CONSTRAINTS USER_DEFINED LOG IMPORT NESTED_TABLE_SET_SETID
                    LEVELS PERCENT PUSH_PRED RESUME NO_CPU_COSTING SIMPLE DISCONNECT WHITESPACE
                    UNLOCK NOMAPPING AUTHID ALLOCATE NCHAR_CS USER_RECYCLEBIN DOMAIN_INDEX_SORT QUERY_BLOCK
                    CYCLE HASH_SJ UNDROP LOGGING OWN PASSING MIN SWITCH SORT BINARY_DOUBLE_NAN NODELAY
                    PLSQL_OPTIMIZE_LEVEL PARTITION_RANGE TIMEZONE_REGION CACHE_INSTANCES SUMMARY
                    INDEX_STATS DISTINGUISHED INTERNAL_CONVERT NO_USE_NL DBTIMEZONE SYS_OP_CAST DOWNGRADE
                    RESET INDEX_DESC NOCYCLE POST_TRANSACTION PLSQL_CODE_TYPE E PARENT MAXLOGFILES
                    NO_FACT UNUSABLE XMLSERIALIZE JAVA NCHAR DEREF OUTLINE SET_TO_JOIN NEEDED VERSIONS
                    INDEX_SCAN EXTENTS SESSIONTIMEZONE PLSQL_DEBUG MONITORING BINARY_DOUBLE_INFINITY STATIC
                    RESUMABLE RANGE MANAGEMENT COMPATIBILITY ATTRIBUTE MAXIMIZE UNDER PARALLEL TIV_GB COMPACT
                    OPTIMAL CUBE_GB INCLUDE_VERSION PARALLEL_INDEX FINE SYSTIMESTAMP INDEXTYPE OUTLINE_LEAF
                    CONNECT_BY_ROOT VECTOR_READ_TRACE NLS_LANGUAGE STRING BINARY_FLOAT_INFINITY UNARCHIVED
                    PROFILE SCN MINUTE MODEL_DONTVERIFY_UNIQUENESS ACCESS
                )
                )
            {
                # the following words are removed of stefans list, because they don't merge
                # at with http://www.petefreitag.com/tools/sql_reserved_words_checker/
                # ID CATEGORY NAME CONTENT VERSION QUEUE BODY TIMEOUT REFERENCE NOTIFICATION PROJECT TRUSTED
                # all reserved sql-words with small letters are from
                # http://www.petefreitag.com/tools/sql_reserved_words_checker/
                # and http://www.ianywhere.com/developer/product_manuals/sqlanywhere/0901/de/html/dbrfde9/00000010.htm
                # 'reference' and 'login' seems to be allowed (checked by www.petefreitag.com)

                if ( $1 && $1 =~ /^$ReservedWord$/i ) {
                    die <<"EOF";
You use a reserved SQL-Word!
Line $Counter: $Line
You can use the following tool for your own checking:
http://www.petefreitag.com/tools/sql_reserved_words_checker/
EOF
                }
            }
            if ( $Line =~ /<\/Table/ ) {
                $TableCreate = 0;
            }
        }
    }

    return;
}

1;
