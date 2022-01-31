*free       
       //--------------------------------------------------------------------------------------------
       // core-i Solutions 
       // www.jeffersonvaughn.com
       // __________________
       //
       // This software is only to be used for demo / learning purposes.
       // It is NOT intended to be used in a live environment.
       //
       // THIS SOFTWARE IS PROVIDED BY THE AUTHOR "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES,
       // INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
       // PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR OR THE AUTHOR'S EMPLOYER BE
       // LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
       // (INCLUDING, BUT NOT LIMITED TO, LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION),
       // HOWEVER CAUSED (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
       // SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
       //
       //--------------------------------------------------------------------------------------------
       //                                                                      
       // Program ID   : crthttpsvr.sqlrpgle                                           
       // Program Desc : create apache http server instance                    
       //
       // Author       : Jay Vaughn
       // Date         : 2018/05/26
       //  
       // Narrative:  user passes in...
       //            - server name
       //            - port
       //            - lib (library that will search for pgm when server intance is invoked)
       //            - ssl?    
       //            - ssl cert optional?
       //            - ssl certificate name (created in DCM)
       //            Incoming parms used to create a fully functional Apache server intance that 
       //            will be started when the user enters command...
       //            STRTCPSVR SERVER(*HTTP) HTTPSVR(<yourServerName>)
       //
       //
       // Note:  for certificate setup via DCM, please consult page 7-8 at
       //        http://jeffersonvaughn.com/documents/coreiRST_04_APICrossPlatform.pdf
       //--------------------------------------------------------------------------------------------

       ctl-opt debug option(*nodebugio)
               dftactgrp(*no)
               actgrp(*new);

       //-----------------------------------------------------------------------
       // SQL Default Options                                                   
       //-----------------------------------------------------------------------
       exec sql
         set option
         commit = *NONE,
         closqlcsr = *ENDMOD,
         datfmt    = *ISO;

       //-----------------------------------------------------------------------
       // program interface
       //-----------------------------------------------------------------------      
       dcl-pi crthttpsvr;
         p_server                      char(10)                    const;
         p_port                        char(5)                     const;
         p_lib                         char(10)                    const;
         p_ssl                         char(1)                     const;
         p_sslCertOpt                  char(1)                     const;
         p_sslCert                     char(50)                    const;
         o_msgId                       char(7);
         o_msgText                     char(80);
       end-pi;

       //-----------------------------------------------------------------------
       // global variables
       //-----------------------------------------------------------------------
       dcl-s g_sqlstmt                 char(2048)                  inz;
       dcl-s g_command                 char(2048)                  inz;
       dcl-s g_server                  char(10)                    inz;
       dcl-s g_lib                     char(10)                    inz;

       //=======================================================================
       // mainline
       //=======================================================================

       if initialize();
         crtHttpSrcMbr();
         crtHttpStmfs();
         crtHttpdConf();
         o_msgId = 'CPF9898';
         o_msgText = 'Apache server ' + %trim(g_server) + 
                     ' successfully setup. Start server with command: ' +
                     'STRTCPSVR SERVER(*HTTP) HTTPSVR(<yourServerName>)';
       endif;

       return;

       //--------------------------------------------------------------------------
       // procedure
       //--------------------------------------------------------------------------
       dcl-proc initialize;
         dcl-pi *n ind;
         end-pi;

         //----------------------------------------
         // local variables
         //----------------------------------------
         // n/a

         *inlr = *on;
        
         exec sql
           values upper(:p_server)
              into :g_server;
         exec sql
           values upper(:p_lib)
              into :g_lib;  

         if p_ssl <> ' '
           and p_sslCert = ' ';
           o_msgId = 'CPF9898';
           o_msgText = 'Must specify ssl certificate name when ssl is selected';
           return *off;
         endif;
       
         return *on;
        
        end-proc;
        //--------------------------------------------------------------------------
        // procedure
        //--------------------------------------------------------------------------
        dcl-proc crtHttpSrcMbr;
          dcl-pi *n ind;
          end-pi;

          //----------------------------------------
          // local variables
          //----------------------------------------
          // n/a

          g_command = 'DLTOVR FILE(QATMHINSTC)';
          exec sql call qsys2.qcmdexc(:g_command);

          g_command = 'CPYF FROMFILE(QUSRSYS/QATMHINSTC) '           +
                           'TOFILE(QUSRSYS/QATMHINSTC) '             +
                           'FROMMBR(APACHEDFT) '                     +
                           'TOMBR(' + %trim(g_server) + ') '         +
                           'MBROPT(*REPLACE)';
          exec sql call qsys2.qcmdexc(:g_command);

          exec sql
            drop alias qtemp.httpalias;

          g_sqlstmt = 'create alias qtemp.httpalias '                  +
                      'for qusrsys.qatmhinstc ('                       +
                                                %trim(g_server)        +
                                             ')';
          exec sql execute immediate :g_sqlstmt;

          exec sql
            delete from qtemp.httpalias;
          exec sql
            insert into qtemp.httpalias
                      values ('-apache -d /www/' concat
                                                 trim(:g_server)
                                                 concat
                              ' -f conf/httpd.conf -AutoStartN');
          exec sql
            drop alias qtemp.httpalias;

          return *on;

        end-proc;

        //--------------------------------------------------------------------------
        // procedure
        //--------------------------------------------------------------------------
        dcl-proc crtHttpStmfs;
          dcl-pi *n ind;
          end-pi;

          //----------------------------------------
          // local variables
          //----------------------------------------
          // n/a

          g_command = 'mkdir '                            +
                                ''''                      +
                                '/www/' + %trim(g_server) +
                                '''';
          exec sql call qsys2.qcmdexc(:g_command);

         g_command = 'mkdir '                            +
                                ''''                      +
                                '/www/' + %trim(g_server) +
                                '/conf'                   +
                                '''';
          exec sql call qsys2.qcmdexc(:g_command);

          g_command = 'mkdir '                            +
                                ''''                      +
                                '/www/' + %trim(g_server) +
                                '/logs'                   +
                                '''';
          exec sql call qsys2.qcmdexc(:g_command);

          g_command = 'mkdir '                            +
                                ''''                      +
                                '/www/' + %trim(g_server) +
                                '/htdocs'                 +
                                '''';
          exec sql call qsys2.qcmdexc(:g_command);

          return *on;

        end-proc;

        //--------------------------------------------------------------------------
        // procedure
        //--------------------------------------------------------------------------
        dcl-proc crtHttpdConf;
          dcl-pi *n ind;
          end-pi;

          //----------------------------------------
          // local variables
          //----------------------------------------
          // n/a

          // build httpd.conf in qtemp...
          g_command = 'DLTF QTEMP/QHTTPD';
          exec sql call qsys2.qcmdexc(:g_command);

          g_command = 'CRTPF FILE(QTEMP/QHTTPD) RCDLEN(200)';
          exec sql call qsys2.qcmdexc(:g_command);

          insertHttpLine('# Configuration originally created by ' +
                         'corei@jeffersonvaughn.com on ' + 
                         %char(%date()) );
          if p_ssl = ' ';
            insertHttpLine('Listen *:' +                                                               
                            %trim(p_port) + ' http');
          else;
            insertHttpLine('LoadModule ibm_ssl_module ' +
                           '/QSYS.LIB/QHTTPSVR.LIB/QZSRVSSL.SRVPGM');
            insertHttpLine('Listen *:' +                                                               
                            %trim(p_port) + ' https');
          endif;
          insertHttpLine('DocumentRoot /www/' + 
                          %trim(g_server) + 
                         '/htdocs');
          insertHttpLine('TraceEnable Off');
          insertHttpLine('Options -FollowSymLinks');
          insertHttpLine('LogFormat "%h %T %l %u %t \"%r\" ' +
                         '%>s %b \"%{Referer}i\" \"%{User-Agent}i\"" combined');
          insertHttpLine('LogFormat "%{Cookie}n \"%r\" %t" cookie');
          insertHttpLine('LogFormat "%{User-agent}i" agent');
          insertHttpLine('LogFormat "%{Referer}i -> %U" referer');
          insertHttpLine('LogFormat "%h %l %u %t \"%r\" %>s %b" common');
          insertHttpLine('CustomLog logs/access_log combined');
          insertHttpLine('LogMaint logs/access_log 7 0');
          insertHttpLine('LogMaint logs/error_log 7 0');
          insertHttpLine('SetEnvIf "User-Agent" "Mozilla/2" nokeepalive');
          insertHttpLine('SetEnvIf "User-Agent" "JDK/1\.0" force-response-1.0');
          insertHttpLine('SetEnvIf "User-Agent" "Java/1\.0" ' +
                         'force-response-1.0');
          insertHttpLine('SetEnvIf "User-Agent" "RealPlayer 4\.0" ' +
                         'force-response-1.0');
          insertHttpLine('SetEnvIf "User-Agent" "MSIE 4\.0b2;" nokeepalive');
          insertHttpLine('SetEnvIf "User-Agent" "MSIE 4\.0b2;" ' +
                         'force-response-1.0');
          insertHttpLine('ScriptAliasMatch /corei/([a-z0-9]*)/.* /qsys.lib/' +
                          %trim(g_lib)  +
                         '.lib/$1.pgm');
          insertHttpLine('SetEnv QIBM_CGI_LIBRARY_LIST_"' +
                         %trim(g_lib) +
                         '"' );
          insertHttpLine('ScriptLog logs/script_log');
          insertHttpLine('LogIOTrackTTFB On');
          insertHttpLine('FRCACustomLog logs/frca.log combined');
          insertHttpLine('DefaultFsCCSID 00037');
          insertHttpLine(' ');
          if p_ssl = ' ';
            insertHttpLine('SetEnv HTTP_PORT ' +
                            %trim(p_port));
          else;
            insertHttpLine('SetEnv HTTPS_PORT ' +
                            %trim(p_port));
          endif;
          insertHttpLine('<Directory /qsys.lib/' +
                          %trim(g_lib) +
                         '.lib>  ');
          insertHttpLine('  require valid-user');
          insertHttpLine('  AuthType basic');
          insertHttpLine('  AuthName "CoreiHttp"');
          insertHttpLine('  PasswdFile %%SYSTEM%%');
          insertHttpLine('  UserId %%CLIENT%%');
          insertHttpLine('</Directory>');

          if p_ssl <> ' ';
            insertHttpLine(' ');                              
            insertHttpLine('<Directory />');                 
            insertHttpLine('  Require all denied');          
            insertHttpLine('</Directory>');                  
            insertHttpLine(' ');                             
            insertHttpLine('<Directory /www/' +              
                                  %trim(g_server) 
                           '/htdocs>');           
           insertHttpLine('  Require all granted');         
           insertHttpLine('</Directory>');                  
           insertHttpLine(' ');                             
            insertHttpLine('<VirtualHost *:' +
                            %trim(p_port) +
                           '>');
            insertHttpLine('  SSLEngine On');
            if p_sslCertOpt <> ' ';
              insertHttpLine('  SSLClientAuth Optional');
            else;
              insertHttpLine('  SSLClientAuth Required');
            endif;
            insertHttpLine('  SSLAppName ' +
                                          %trim(p_sslCert));
            insertHttpLine('  SSLProtocolDisable SSLv2 SSLv3');
            insertHttpLine('</VirtualHost>');
          endif;


          // move to ifs...
          g_command = 'CPYTOIMPF FROMFILE(QTEMP/QHTTPD) '              +
                                'TOSTMF('                              +
                                             ''''                      +
                                             '/www/' + %trim(g_server) +
                                             '/conf/httpd.conf'        +
                                             ''''                      +
                                       ') '                            +
                                'MBROPT(*REPLACE) '                    +
                                'RCDDLM(*CRLF) '                       +
                                'FROMCCSID(37) '                       +
                                'STMFCCSID(819) '                      +
                                'STRDLM(*NONE)';
          exec sql call qsys2.qcmdexc(:g_command);

          g_command = 'CHGAUT OBJ('                                    +
                                ''''                                   +
                                '/www/' + %trim(g_server)              +
                                '/conf/httpd.conf'                     +
                                ''''                                   +
                                ') '                                   +
                      'USER(QTMHHTTP) '                                +
                      'DTAAUT(*RWX) '                                  +
                      'OBJAUT(*ALL)';
          exec sql call qsys2.qcmdexc(:g_command);

          g_command = 'GRTOBJAUT OBJ('                                 +
                                      %trim(g_lib)                     +
                                    ') '                               +
                                'OBJTYPE(*LIB) '                       +
                                'USER(QTMHHTTP QTMHHTP1) '             +
                                'AUT(*USE)';
          exec sql call qsys2.qcmdexc(:g_command);
  
          g_command = 'GRTOBJAUT OBJ(' + %trim(g_lib) + '/*ALL) '      +
                                'OBJTYPE(*ALL) '                       +
                                'USER(QTMHHTTP QTMHHTP1) '             +
                                'AUT(*ALL)';
          exec sql call qsys2.qcmdexc(:g_command);

          return *on;

        end-proc;

        //--------------------------------------------------------------------------
        // procedure
        //--------------------------------------------------------------------------
        dcl-proc insertHttpLine;
          dcl-pi *n ind;
            i_line                  char(200)                 const;
          end-pi;

          //----------------------------------------
          // local variables
          //----------------------------------------
          // n/a

          exec sql
            insert into qtemp.qhttpd (qhttpd)
                            values  (:i_line);

          return *on;

        end-proc;

