#define PERL_NO_GET_CONTEXT
#ifdef __cplusplus
extern "C" {
#endif
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#include "ppport.h"
#ifdef __cplusplus
}
#endif

#ifdef do_open
#undef do_open
#endif
#ifdef do_close
#undef do_close
#endif

#include <string>
#include <vector>
#include "kytea/kytea.h"
#include "kytea/kytea-struct.h"
using namespace std;
using namespace kytea;


class TextKyTea
{
private:
    Kytea          kytea;
    StringUtil*    util;
    KyteaConfig*   config;
    KyteaSentence  sentence;
public:
    void        read_model(const char* model)     { kytea.readModel(model); }
    void        write_model(const char* filename) { kytea.writeModel(filename); }
    void        train_all()                       { kytea.trainAll(); }
    void        analyze()                         { kytea.analyze(); }
    StringUtil* _get_string_util()                { return util; }

    void _init(
        const char* model,    bool nows,             bool notags,          vector<int> notag,
        bool nounk,           unsigned int unkbeam,  unsigned int tagmax,  const char* deftag,
        const char* unktag,   const char* wordbound, const char* tagbound, const char* elembound,
        const char* unkbound, const char* skipbound, const char* nobound,  const char* hasbound
    )
    {
        read_model(model);
        util   = kytea.getStringUtil();
        config = kytea.getConfig();

        config->setDoWS(!nows);
        config->setDoTags(!notags);

        vector<int>::const_iterator it;
        for (it = notag.begin(); it != notag.end(); ++it)
            if (*it > 0) config->setDoTag(*it - 1, false);

        config->setDoUnk(!nounk);
        config->setUnkBeam(unkbeam);
        config->setTagMax(tagmax);
        config->setDefaultTag(deftag);
        config->setUnkTag(unktag);
        config->setWordBound(wordbound);
        config->setTagBound(tagbound);
        config->setElemBound(elembound);
        config->setUnkBound(unkbound);
        config->setSkipBound(skipbound);
        config->setNoBound(nobound);
        config->setHasBound(hasbound);
    }
    KyteaSentence* parse(const char* str)
    {
        sentence = util->mapString(str);
        kytea.calculateWS(sentence);

        for (int i = 0; i < config->getNumTags(); ++i)
            if ( config->getDoTag(i) ) kytea.calculateTags(sentence, i);

        return &sentence;
    }
};

MODULE = Text::KyTea    PACKAGE = Text::KyTea

PROTOTYPES: DISABLE

TextKyTea *
_init_text_kytea(char* CLASS, SV* args_ref)
    PREINIT:
        HV* hv      = (HV*)sv_2mortal( (SV*)newHV() );

        SV* model   = sv_newmortal();
        SV* nows    = sv_newmortal();
        SV* notags  = sv_newmortal();
        SV* notag   = sv_newmortal();
        SV* nounk   = sv_newmortal();
        SV* unkbeam = sv_newmortal();

        SV* tagmax = sv_newmortal();
        SV* deftag = sv_newmortal();
        SV* unktag = sv_newmortal();

        SV* wordbound = sv_newmortal();
        SV* tagbound  = sv_newmortal();
        SV* elembound = sv_newmortal();
        SV* unkbound  = sv_newmortal();
        SV* skipbound = sv_newmortal();
        SV* nobound   = sv_newmortal();
        SV* hasbound  = sv_newmortal();

        AV* notag_av  = (AV*)sv_2mortal( (SV*)newAV() );
        vector<int> notag_vec;

    CODE:
        hv = (HV*)SvRV(args_ref);

        model   = *hv_fetchs(hv, "model",   FALSE);
        nows    = *hv_fetchs(hv, "nows",    FALSE);
        notags  = *hv_fetchs(hv, "notags",  FALSE);
        notag   = *hv_fetchs(hv, "notag",   FALSE);
        nounk   = *hv_fetchs(hv, "nounk",   FALSE);
        unkbeam = *hv_fetchs(hv, "unkbeam", FALSE);

        tagmax = *hv_fetchs(hv, "tagmax", FALSE);
        deftag = *hv_fetchs(hv, "deftag", FALSE);
        unktag = *hv_fetchs(hv, "unktag", FALSE);

        wordbound = *hv_fetchs(hv, "wordbound", FALSE);
        tagbound  = *hv_fetchs(hv, "tagbound",  FALSE);
        elembound = *hv_fetchs(hv, "elembound", FALSE);
        unkbound  = *hv_fetchs(hv, "unkbound",  FALSE);
        skipbound = *hv_fetchs(hv, "skipbound", FALSE);
        nobound   = *hv_fetchs(hv, "nobound",   FALSE);
        hasbound  = *hv_fetchs(hv, "hasbound",  FALSE);

        notag_av = (AV*)SvRV(notag);

        for (int i = 0; av_len(notag_av) >= i; ++i)
            notag_vec.push_back( SvIV( *av_fetch(notag_av, i, FALSE) ) );

        TextKyTea* tkt = new TextKyTea();
        tkt->_init(
            SvPV_nolen(model),    SvUV(nows),            SvUV(notags),         notag_vec,
            SvUV(nounk),          SvUV(unkbeam),         SvUV(tagmax),         SvPV_nolen(deftag),
            SvPV_nolen(unktag),   SvPV_nolen(wordbound), SvPV_nolen(tagbound), SvPV_nolen(elembound),
            SvPV_nolen(unkbound), SvPV_nolen(skipbound), SvPV_nolen(nobound),  SvPV_nolen(hasbound)
        );

        RETVAL = tkt;
    OUTPUT:
        RETVAL


void
TextKyTea::read_model(const char* model)

void
TextKyTea::write_model(const char* filename)

KyteaSentence*
TextKyTea::parse(const char* str)
