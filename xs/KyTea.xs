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
    void read_model(const char* model_path)
    {
        kytea.readModel(model_path);
    }
    void _init(const char* model_path)
    {
        read_model(model_path);
        util   = kytea.getStringUtil();
        config = kytea.getConfig();
    }
    StringUtil* _get_string_util()
    {
        return util;
    }
    KyteaSentence* parse(const char* str)
    {
        sentence = util->mapString(str);
        kytea.calculateWS(sentence);

        for (int i = 0; i < config->getNumTags(); ++i)
            kytea.calculateTags(sentence,i);

        return &sentence;
    }
};

MODULE = Text::KyTea    PACKAGE = Text::KyTea

PROTOTYPES: DISABLE

TextKyTea *
_init_text_kytea(char* CLASS, SV* args_ref)
    PREINIT:
        HV* hv         = (HV*)sv_2mortal( (SV*)newHV() );
        SV* model_path = sv_newmortal();
    CODE:
        hv = (HV*)SvRV(args_ref);

        model_path = *hv_fetchs(hv, "model_path", FALSE);

        TextKyTea * tkt = new TextKyTea();
        tkt->_init( SvPV_nolen(model_path) );

        RETVAL = tkt;
    OUTPUT:
        RETVAL


void
TextKyTea::read_model(const char* model_path)

KyteaSentence*
TextKyTea::parse(const char* str)
