#!/usr/bin/env python3
"""Probe installed Node LSP servers over stdio when sandboxed Neovim attach fails."""
from pathlib import Path
import json,os,select,subprocess,time
ROOT=Path(__file__).resolve().parents[2]
BASE=ROOT/'build/verification'
class RPC:
    def __init__(self,cmd):
        self.p=subprocess.Popen(cmd,stdin=subprocess.PIPE,stdout=subprocess.PIPE,stderr=subprocess.PIPE)
        self.data=b'';self.sequence=0
    def send(self,message):
        data=json.dumps(message).encode()
        self.p.stdin.write(f'Content-Length: {len(data)}\r\n\r\n'.encode()+data);self.p.stdin.flush()
    def notification(self,method,params):self.send({'jsonrpc':'2.0','method':method,'params':params})
    def request(self,method,params,timeout=8):
        self.sequence+=1;ident=self.sequence
        self.send({'jsonrpc':'2.0','id':ident,'method':method,'params':params})
        until=time.monotonic()+timeout
        while time.monotonic()<until:
            split=self.data.find(b'\r\n\r\n')
            if split>=0:
                header=self.data[:split].decode()
                size=int(next(x.split(':',1)[1] for x in header.split('\r\n') if x.lower().startswith('content-length:')))
                if len(self.data)>=split+4+size:
                    message=json.loads(self.data[split+4:split+4+size]);self.data=self.data[split+4+size:]
                    if message.get('id')==ident and 'method' not in message:
                        if 'error' in message:raise RuntimeError(str(message['error']))
                        return message.get('result')
                    if 'id' in message and 'method' in message:
                        value=[{} for _ in message.get('params',{}).get('items',[])] if message['method']=='workspace/configuration' else None
                        self.send({'jsonrpc':'2.0','id':message['id'],'result':value})
                    continue
            ready,_,_=select.select([self.p.stdout,self.p.stderr],[],[],max(0,min(.2,until-time.monotonic())))
            for stream in ready:
                data=os.read(stream.fileno(),65536)
                if stream is self.p.stdout:self.data+=data
            if self.p.poll() is not None:raise RuntimeError(f'server exited {self.p.returncode}')
        raise TimeoutError(method)
    def close(self):
        self.p.terminate()
        try:self.p.wait(timeout=2)
        except subprocess.TimeoutExpired:self.p.kill();self.p.wait()

def main():
    home=Path.home();node=home/'.local/share/mise/installs/node/22.22.2/bin/node'
    if not node.exists():node=home/'.local/share/mise/installs/node/latest/bin/node'
    servers={
      'vtsls':('typescript','typescript',home/'.local/share/nvim/mason/packages/vtsls/node_modules/@vtsls/language-server/bin/vtsls.js'),
      'pyright':('python','python',home/'.local/share/nvim/mason/packages/pyright/node_modules/pyright/langserver.index.js'),
    }
    results=[]
    inventory=json.loads((BASE/'inventory.json').read_text())
    for name,(lang,language_id,server) in servers.items():
        item={'name':name,'language':lang};rpc=None
        try:
            path=Path(inventory[lang]);uri=path.as_uri()
            rpc=RPC([str(node),str(server),'--stdio'])
            init=rpc.request('initialize',{'processId':None,'rootUri':path.parent.as_uri(),'workspaceFolders':[{'uri':path.parent.as_uri(),'name':'verification'}],'capabilities':{'textDocument':{'semanticTokens':{'requests':{'full':True},'tokenTypes':[],'tokenModifiers':[],'formats':['relative']}}}})
            rpc.notification('initialized',{})
            rpc.notification('textDocument/didOpen',{'textDocument':{'uri':uri,'languageId':language_id,'version':1,'text':path.read_text()}})
            item['status']='initialized';item['semantic_provider']=init.get('capabilities',{}).get('semanticTokensProvider')
            if item['semantic_provider']:
                tokens=rpc.request('textDocument/semanticTokens/full',{'textDocument':{'uri':uri}},timeout=15)
                item['tokens']=tokens;item['status']='tokens-received' if tokens and tokens.get('data') else 'no-tokens'
        except Exception as exc:item['status']='blocked';item['reason']=str(exc)
        finally:
            if rpc:rpc.close()
        results.append(item)
    target=BASE/'reports/lsp-protocol.json';target.parent.mkdir(exist_ok=True)
    target.write_text(json.dumps(results,indent=2)+'\n')
    print([(r['name'],r['status']) for r in results])
if __name__=='__main__':main()
