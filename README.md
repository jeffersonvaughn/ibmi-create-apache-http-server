# ibmi-create-apache-http-server
with a few inputs deploy a fully functional http server for REST services

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
       // Note:  for certificate setup via DCM, please consult page 7-8 at
       //        http://jeffersonvaughn.com/documents/coreiRST_04_APICrossPlatform.pdf
       //--------------------------------------------------------------------------------------------

