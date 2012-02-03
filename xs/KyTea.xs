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

static const string tkt_keys[4] = {"surface", "feature", "score", "tags"};

class TextKyTea
{
private:
    Kytea          kytea;
    StringUtil*    util;
    KyteaConfig*   config;
    KyteaSentence  sentence;
public:
    void        read_model(const char* model)     { kytea.readModel(model); }
    void        train_all()                       { kytea.trainAll(); }
    void        analyze()                         { kytea.analyze(); }
    StringUtil* _get_string_util()                { return util; }

    void _init(
        const char* model,    const bool nows,             const bool notags,          const vector<int> notag,
        const bool nounk,     const unsigned int unkbeam,  const unsigned int tagmax,  const char* deftag,
        const char* unktag,   const char* wordbound,       const char* tagbound,       const char* elembound,
        const char* unkbound, const char* skipbound,       const char* nobound,        const char* hasbound
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
        HV* hv    = (HV*)sv_2mortal( (SV*)newHV() );
        AV* notag = (AV*)sv_2mortal( (SV*)newAV() );
        vector<int> notag_vec;

    CODE:
        hv = (HV*)SvRV(args_ref);

        notag = (AV*)SvRV( *hv_fetchs(hv, "notag", FALSE) );

        for (int i = 0; av_len(notag) >= i; ++i)
            notag_vec.push_back( SvIV( *av_fetch(notag, i, FALSE) ) );

        TextKyTea* tkt = new TextKyTea();

        tkt->_init(
            SvPV_nolen( *hv_fetchs(hv, "model", FALSE) ),
            SvUV( *hv_fetchs(hv, "nows",    FALSE) ),
            SvUV( *hv_fetchs(hv, "notags",  FALSE) ),
            notag_vec,
            SvUV( *hv_fetchs(hv, "nounk",   FALSE) ),
            SvUV( *hv_fetchs(hv, "unkbeam", FALSE) ),
            SvUV( *hv_fetchs(hv, "tagmax",  FALSE) ),
            SvPV_nolen( *hv_fetchs(hv, "deftag",    FALSE) ),
            SvPV_nolen( *hv_fetchs(hv, "unktag",    FALSE) ),
            SvPV_nolen( *hv_fetchs(hv, "wordbound", FALSE) ),
            SvPV_nolen( *hv_fetchs(hv, "tagbound",  FALSE) ),
            SvPV_nolen( *hv_fetchs(hv, "elembound", FALSE) ),
            SvPV_nolen( *hv_fetchs(hv, "unkbound",  FALSE) ),
            SvPV_nolen( *hv_fetchs(hv, "skipbound", FALSE) ),
            SvPV_nolen( *hv_fetchs(hv, "nobound",   FALSE) ),
            SvPV_nolen( *hv_fetchs(hv, "hasbound",  FALSE) )
        );

        RETVAL = tkt;
    OUTPUT:
        RETVAL


void
TextKyTea::read_model(const char* model)

KyteaSentence*
TextKyTea::parse(const char* str)
