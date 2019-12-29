#include<iostream>
#include<cstdio>
#include<cstdlib>
#include<string>
#include<regex>
#include<map>
#include<vector>
#include<stack>
#include<tuple>
using namespace std;
const int D = 9360;
const int N = D/2*7;

const int MAXA = 65536;

int reg[8], cf, sf, zf, of, f;
int kvm, spm, cvm, m5, m6, pc;
uint8_t ram[MAXA];
vector<tuple<void(*)(string&, string&), string, string>> prog;
map<string, int> labels;
map<int, string> debugl;
stack<int> pcstack;
void logtrace();
void error(const string& msg, const string& lv = "", const string& rv = "") {
    cout << "Error " << msg << ' ' << lv << "," << rv << endl;
    exit(1);
}
void mov(string &lv, string &rv) {
    int r;
    if (lv[0] == 'r') {
        int lviv = reg[lv[1] - '0'];
        if (rv[0] == 'r')
            r = reg[rv[1] - '0'] = lviv;
        else if (rv[0] == '(') { //"(r2)+"
            r = lviv;
            ram[reg[2]++] = r & 0xff;
            ram[reg[2]++] = r >> 8;
            reg[2] &= 0xffff;
        } else if (rv[0] == '1') { //"1(r1)"
            r = lviv;
            ram[reg[1] + m6] = r & 0xff;
            ram[reg[1] + m6 + 1] = r >> 8;
        } else if (rv[2] == 'k') //"*$kv"
            r = kvm = lviv;
        else if (rv[1] == 's') //"*sp"
            r = spm = lviv;
        else if (rv[2] == 'c') //"*$cv"
            r = cvm = lviv;
        else if (rv[3] == '6') //"*$m6+2"
            r = m6 = lviv;
        else if (rv[3] == '5') //"*$m5+2"
            r = m5 = lviv;
        else
            error("MOV", lv, rv);
    } else if (rv[0] == 'r') {
        int &rviv = reg[rv[1] - '0'];
        int sm;
        if (lv[3] == 'N') //"*$_N"
            rviv = N;
        else if (lv[3] == 'r') //"*$_ra"
            rviv = 2;
        else if (lv[2] == 'u') //"$buf4"
            rviv = MAXA - 4;
        else if (sscanf(lv.c_str(), "$%u", &sm)) {
            rviv = sm;
            if (labels["kvs"] == pc)
                rviv = kvm;
        } else if (lv[1] == 's') //"*sp"
            rviv = spm;
        else
            error("MOV", lv, rv);
        r = rviv;
    } else
        error("MOV", lv, rv);
    zf = r == 0;
    sf = r & 0x8000;
    pc++;
}
void movb(string &lv, string &rv) {
    int r;
    if (lv[0] == 'r' && rv == "(r1)+") {
        r = ram[reg[1]] = reg[lv[1] - '0'] & 0xff;
        reg[1] = (reg[1] + 1) & 0xffff;
    } else
        error("MOVB", lv, rv);
    zf = (r & 0xffff) == 0;
    sf = r & 0x8000;
    pc++;
}
void add(string &lv, string &rv) {
    int sm;
    int &rviv = reg[rv[1] - '0'];
    if (lv[0] == 'r')
        rviv += reg[lv[1] - '0'];
    else if (lv[2] == 'c') //"*$cv"
        rviv += cvm;
    else if (sscanf(lv.c_str(), "$%u", &sm))
        rviv += sm;
    else
        error("ADD", lv, rv);
    cf = rviv & 0x10000;
    rviv &= 0xffff;
    zf = rviv == 0;
    sf = rviv & 0x8000;
    pc++;
}
void sub(string &lv, string &rv) {
    int r;
    if (lv[0] == 'r' && rv[0] == 'r') {
        r = reg[rv[1] - '0'] -= reg[lv[1] - '0'];
        reg[rv[1] - '0'] &= 0xffff;
    } else if (lv == "$14." && rv == "*$kv")
        r = kvm -= 14;
    else
        error("SUB", lv, rv);
    cf = r & 0x10000;
    zf = (r & 0xffff) == 0;
    sf = r & 0x8000;
    pc++;
}
void cmp(string &lv, string &rv) {
    int r = reg[lv[1] - '0'] - reg[rv[1] - '0'];
    cf = r & 0x10000;
    zf = (r & 0xffff) == 0;
    sf = r & 0x8000;
    pc++;
}
void jsr(string &lv, string &rv) {
    pcstack.push(pc + 1);
    pc = labels[rv];
}
void rts(string &lv, string &rv) {
    pc = pcstack.top();
    pcstack.pop();
}
void decr(string &lv, string &rv) {
    int lvi = lv[1] - '0';
    reg[lvi] = (reg[lvi] - 1) & 0xffff;
    zf = reg[lvi] == 0;
    sf = reg[lvi] & 0x8000;
    pc++;
}
void inc(string &lv, string &rv) {
    int lvi = lv[1] - '0';
    reg[lvi] = (reg[lvi] + 1) & 0xffff;
    zf = reg[lvi] == 0;
    sf = reg[lvi] & 0x8000;
    pc++;
}
void asl(string &lv, string &rv) {
    int lvi = lv[1] - '0';
    cf = reg[lvi] & 0x8000;
    reg[lvi] = (reg[lvi] << 1) & 0xffff;
    zf = reg[lvi] == 0;
    sf = reg[lvi] & 0x8000;
    pc++;
}
void asr(string &lv, string &rv) {
    int lvi = lv[1] - '0';
    cf = reg[lvi] & 1;
    reg[lvi] >>= 1;
    reg[lvi] |= (reg[lvi] & 0x4000) << 1;
    zf = reg[lvi] == 0;
    sf = reg[lvi] & 0x8000;
    pc++;
}
void rol(string &lv, string &rv) {
    int lvi = lv[1] - '0';
    reg[lvi] <<= 1;
    reg[lvi] |= !!cf;
    cf = reg[lvi] & 0x10000;
    reg[lvi] &= 0xffff;
    zf = reg[lvi] == 0;
    sf = reg[lvi] & 0x8000;
    pc++;
}
void ror(string &lv, string &rv) {
    int lvi = lv[1] - '0';
    int cf1 = reg[lvi] & 1;
    reg[lvi] >>= 1;
    reg[lvi] |= !!cf << 15;
    cf = cf1;
    zf = reg[lvi] == 0;
    sf = reg[lvi] & 0x8000;
    pc++;
}
void adc(string &lv, string &rv) {
    int r = reg[lv[1] - '0'] += !!cf;
    reg[lv[1] - '0'] &= 0xffff;
    cf = r & 0x10000;
    zf = (r & 0xffff) == 0;
    sf = r & 0x8000;
    pc++;
}
void sbc(string &lv, string &rv) {
    int r = reg[lv[1] - '0'] -= !!cf;
    reg[lv[1] - '0'] &= 0xffff;
    cf = r & 0x10000;
    zf = (r & 0xffff) == 0;
    sf = r & 0x8000;
    pc++;
}
void clr(string &lv, string &rv) {
    if (lv[0] == 'r')
        reg[lv[1] - '0'] = 0;
    else if (lv[2] == 'c')  //"*$cv"
        cvm = 0;
    else
        error("CLR", lv);
    zf = 1;
    cf = sf = 0;
    pc++;
}
void mul(string &lv, string &rv) {
    int r;
    if (lv[1] == '(' && rv[1] == '2' && pc == labels["m5"]) { //lv == "2(r1)", rv == "r2"
        int f1 = (ram[reg[1] + m5 + 1] << 8) + ram[reg[1] + m5];
        int f2 = reg[2];
        if (f1 & 0x8000) f1 |= ~0x7fff;
        if (f2 & 0x8000) f2 |= ~0x7fff;
        r = f1*f2;
    } else
        error("MUL", lv, rv);
    sf = r < 0;
    zf = r == 0;
    of = 0;
    cf = (r > 0x7fff) || (r < -0x8000);
    reg[2] = (r >> 16)&0xffff;
    reg[3] = r & 0xffff;
    pc++;
}
void divi(string &lv, string &rv) {
    int q;
    int rvi = rv[1] - '0';
    int &rviv_hi = reg[rvi];
    int &rviv_lo = reg[rvi | 1];
    int lvv;
    if (lv[0] == 'r')
        lvv = reg[lv[1] - '0'];
    else if (lv == "$10000.")
        lvv = 10000;
    else
        error("DIV", lv, rv);
    if (lvv == 0) {
        sf = 0;
        zf = of = cf = 1;
        pc++;
        return;
    }
    int src = rviv_hi << 16 | rviv_lo;
    if (src == 0x8000'0000 && lvv == 0xffff) {
        of = 1;
        sf = zf = cf = 0;
        pc++;
        return;
    }
    if (lvv & 0x8000) lvv |= ~0x7fff;
    if (rviv_hi & 0x8000) src |= ~0x7fff'ffff;
    q = src/lvv;
    sf = q < 0;
    if (q > 0x7fff || q < -0x8000) {
        of = 1;
        zf = cf = 0;
        pc++;
        return;
    }
    rviv_hi = q & 0xffff;
    rviv_lo = src - lvv*q & 0xffff;
    zf = q == 0;
    of = cf = 0;
    pc++;
}
void sob(string &lv, string &rv) {
    if (--reg[lv[1] - '0'] != 0)
        pc = labels[rv];
    else
        pc++;
}
void br(string &lv, string &rv) {
    pc = labels[lv];
}
void bcc(string &lv, string &rv) {
    if (cf)
        pc++;
    else
        pc = labels[lv];
}
void bne(string &lv, string &rv) {
    if (zf)
        pc++;
    else
        pc = labels[lv];
}
void bpl(string &lv, string &rv) {
    if (sf)
        pc++;
    else
        pc = labels[lv];
}
void bcs(string &lv, string &rv) {
    if (cf)
        pc = labels[lv];
    else
        pc++;
}
void beq(string &lv, string &rv) {
    if (zf)
        pc = labels[lv];
    else
        pc++;
}
void bmi(string &lv, string &rv) {
    if (sf)
        pc = labels[lv];
    else
        pc++;
}
void bvs(string &lv, string &rv) {
    if (of)
        pc = labels[lv];
    else
        pc++;
}
void sys(string &lv, string &rv) {
    printf("%c%c%c%c", ram[MAXA - 4], ram[MAXA - 3], ram[MAXA - 2], ram[MAXA - 1]);
    pc++;
}
void halt(string &lv, string &rv) {
    pc = -1;
}
void dprint(string &lv, string &rv) {
    cout << "[debug print] ";
    //logtrace();
    pc++;
}
void parse() {
    regex empty_line("^#|^\\s*/|^\\s*$");
    regex label("^([^\\s:]*):\\s*(/.*)?$");
    regex mov_re("^([^\\s:]*):?\\s+mov\\s+([^,]+),([^\\s]+)");
    regex mul_re("^([^\\s:]*):?\\s+mul\\s+([^,]+),([^\\s]+)");
    regex divi_re("^([^\\s:]*):?\\s+div\\s+([^,]+),([^\\s]+)");
    regex movb_re("^([^\\s:]*):?\\s+movb\\s+([^,]+),([^\\s]+)");
    regex add_re("^([^\\s:]*):?\\s+add\\s+([^,]+),([^\\s]+)");
    regex sub_re("^([^\\s:]*):?\\s+sub\\s+([^,]+),([^\\s]+)");
    regex cmp_re("^([^\\s:]*):?\\s+cmp\\s+([^,]+),([^\\s]+)");
    regex sys_re("^([^\\s:]*):?\\s+sys\\s+([^;]+);([^\\s]+)");
    regex jsr_re("^([^\\s:]*):?\\s+jsr\\s+([^,]+),\\*\\$([^\\s]+)");
    regex tst_re("^([^\\s:]*):?\\s+tst\\s+([^\\s]+)");
    regex decr_re("^([^\\s:]*):?\\s+dec\\s+([^\\s]+)");
    regex inc_re("^([^\\s:]*):?\\s+inc\\s+([^\\s]+)");
    regex sob_re("^([^\\s:]*):?\\s+sob\\s+([^,]+),([^\\s]+)");
    regex clr_re("^([^\\s:]*):?\\s+clr\\s+([^\\s]+)");
    regex asl_re("^([^\\s:]*):?\\s+asl\\s+([^\\s]+)");
    regex asr_re("^([^\\s:]*):?\\s+asr\\s+([^\\s]+)");
    regex adc_re("^([^\\s:]*):?\\s+adc\\s+([^\\s]+)");
    regex sbc_re("^([^\\s:]*):?\\s+sbc\\s+([^\\s]+)");
    regex ror_re("^([^\\s:]*):?\\s+ror\\s+([^\\s]+)");
    regex rol_re("^([^\\s:]*):?\\s+rol\\s+([^\\s]+)");
    regex bpl_re("^([^\\s:]*):?\\s+bpl\\s+([^\\s]+)");
    regex bmi_re("^([^\\s:]*):?\\s+bmi\\s+([^\\s]+)");
    regex bcc_re("^([^\\s:]*):?\\s+bcc\\s+([^\\s]+)");
    regex bcs_re("^([^\\s:]*):?\\s+bcs\\s+([^\\s]+)");
    regex bne_re("^([^\\s:]*):?\\s+bne\\s+([^\\s]+)");
    regex beq_re("^([^\\s:]*):?\\s+beq\\s+([^\\s]+)");
    regex bvs_re("^([^\\s:]*):?\\s+bvs\\s+([^\\s]+)");
    regex br_re("^([^\\s:]*):?\\s+br\\s+([^\\s]+)");
    regex rts_re("^([^\\s:]*):?\\s+rts\\s+([^\\s]+)");
    regex halt_re("^([^\\s:]*):?\\s+halt\\s*$");
    regex dprint_re("^([^\\s:]*):?\\s+dprint\\s*$");
    smatch sm;
    string s;
#define PARSE2(M) else if (regex_search(s, sm, M##_re)) {\
            if (!sm.str(1).empty()) {labels[sm.str(1)] = prog.size();debugl[prog.size()] = sm.str(1);}\
            prog.push_back({M, sm.str(2), sm.str(3)});}
#define PARSE1(M) else if (regex_search(s, sm, M##_re)) {\
            if (!sm.str(1).empty()) {labels[sm.str(1)] = prog.size();debugl[prog.size()] = sm.str(1);}\
            prog.push_back({M, sm.str(2), ""});}
    while (cin) {
        getline(cin, s);
        if (regex_search(s, sm, empty_line))
            continue;
        else if (regex_search(s, sm, label)) {
            if (!sm.str(1).empty()) {labels[sm.str(1)] = prog.size();debugl[prog.size()] = sm.str(1);}
        } else if (regex_search(s, sm, tst_re)) {
            if (!sm.str(1).empty()) {labels[sm.str(1)] = prog.size();debugl[prog.size()] = sm.str(1);}
        } else if (regex_search(s, sm, halt_re)) {
            if (!sm.str(1).empty()) {labels[sm.str(1)] = prog.size();debugl[prog.size()] = sm.str(1);}
            prog.push_back({halt, "", ""});
        } else if (regex_search(s, sm, dprint_re)) {
            if (!sm.str(1).empty()) {labels[sm.str(1)] = prog.size();debugl[prog.size()] = sm.str(1);}
            prog.push_back({dprint, "", ""});
        } PARSE2(mov) PARSE2(movb) PARSE2(add) PARSE2(sub) PARSE1(decr)
        PARSE1(inc) PARSE2(sob) PARSE1(clr) PARSE1(asl) PARSE1(asr)
        PARSE1(rol) PARSE1(ror) PARSE1(adc) PARSE1(sbc) PARSE1(br)
        PARSE1(bcc) PARSE1(bcs) PARSE1(bpl) PARSE1(bmi) PARSE1(bne)
        PARSE1(beq) PARSE1(bvs) PARSE2(cmp) PARSE2(mul) PARSE2(jsr)
        PARSE1(rts) PARSE2(sys) PARSE2(divi)
        else
            cout << "Parse error: " << s << endl;
    }
}

map<void*, const char*> debugi = {{(void*)mov, "mov"}, {(void*)movb, "movb"}, {(void*)mul, "mul"}, {(void*)decr, "dec"}, {(void*)inc, "inc"}, {(void*)divi, "div"}, {(void*)bcc, "bcc"}, {(void*)bcs, "bcs"}, {(void*)bmi, "bmi"}, {(void*)bpl, "bpl"}, {(void*)beq, "beq"}, {(void*)bne, "bne"}, {(void*)bvs, "bvs"}, {(void*)br, "br"}, {(void*)halt, "halt"}, {(void*)asl, "asl"}, {(void*)asr, "asr"}, {(void*)ror, "ror"}, {(void*)rol, "rol"}, {(void*)jsr, "jsr"}, {(void*)rts, "rts"}, {(void*)add, "add"}, {(void*)adc, "adc"}, {(void*)sub, "sub"}, {(void*)sbc, "sbc"}, {(void*)sob, "sob"}, {(void*)clr, "clr"}, {(void*)cmp, "cmp"}, {(void*)sys, "sys"}, {(void*)dprint, "dprint"}};

void logtrace(){
    for(int i = 0; i < 6; i++)
        cout << " r" << i <<"=" << hex << reg[i];
    cout << " cf=" << !!cf << " sf=" << !!sf << " zf=" << !!zf << " of=" << of << " cv=" << cvm << " kv=" << kvm << " *sp=" << spm << endl;
    cout << dec << pc << "[" << debugl[pc] << "] "<< debugi[(void*)get<0>(prog[pc])] << ' ' << get<1>(prog[pc]) << ' ' << get<2>(prog[pc]) << endl;
}
void run() {
    while (pc >= 0) {
        //logtrace();
        (*get<0>(prog[pc]))(get<1>(prog[pc]), get<2>(prog[pc]));
    }
}
void listing() {
    for (int i = 0; i < prog.size(); ++i) cout << i << "[" << debugl[i] << "] "<< debugi[(void*)get<0>(prog[i])] << ' ' << get<1>(prog[i]) << ' ' << get<2>(prog[i]) << endl;
}
void refs() {
    for (auto i: labels) cout << i.first << ' ' << i.second << endl;
}
int main() {
    cout << "parse\n";
    parse();
    //listing();
    //refs();
    cout << "run!\n";
    run();
    return 0;
}

