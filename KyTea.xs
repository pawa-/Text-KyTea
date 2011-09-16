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

#include <vector>
#include <map>
#include <string>
#include <sstream>
#include "kytea/kytea.h"
#include "kytea/kytea-struct.h"
using namespace std;
using namespace kytea;

const int NUM_OF_TAGS = 5;
const string KEY_NAME[NUM_OF_TAGS] = {"feature", "pron", "undef1", "undef2", "undef3"};

class TextKyTea
{
private:
    Kytea kytea;
    StringUtil*  util;
    KyteaConfig* config;
public:
    void _init(char* model_path)
    {
        kytea.readModel(model_path);
        util   = kytea.getStringUtil();
        config = kytea.getConfig();
    }
    vector< map<string, string> > parse(char* str)
    {
        KyteaSentence sentence(util->mapString(str));
        kytea.calculateWS(sentence);

        for (int i = 0; i < config->getNumTags(); ++i)
            kytea.calculateTags(sentence,i);

        const KyteaSentence::Words & words = sentence.words;

        vector< map<string, string> > result;

        for (int i = 0; i < (int)words.size(); ++i)
        {
            string surf = util->showString(words[i].surf);

            map<string, string> m;
            m["surface"] = surf;

            #ifdef DIAG
            PerlIO_printf( PerlIO_stderr(), "%s", surf.c_str() );
            #endif

            for(int j = 0; j < (int)words[i].tags.size(); ++j)
            {
                if (j >= NUM_OF_TAGS) croak("unexpected tag was appeared");

                #ifdef DIAG
                PerlIO_printf(PerlIO_stderr(), "\t");
                #endif

                string tag   = util->showString(words[i].tags[j][0].first);
                double score = words[i].tags[j][0].second;

                #ifdef DIAG
                PerlIO_printf( PerlIO_stderr(), " %s", tag.c_str() );
                PerlIO_printf(PerlIO_stderr(), "/%f", score);
                #endif

                // store result
                m[ KEY_NAME[j] ]  = tag;
                string score_name = KEY_NAME[j] + "_score";

                stringstream ss_score;
                ss_score << score;
                m[score_name] = ss_score.str();
            }

            #ifdef DIAG
            PerlIO_printf(PerlIO_stderr(), "\n");
            #endif

            result.push_back(m);
        }

        #ifdef DIAG
        for (int i = 0; i < (int)result.size(); ++i)
        {
            map<string, string> m = result[i];
            map<string, string>::iterator it = m.begin();

            while ( it != m.end() )
            {
                PerlIO_printf( PerlIO_stderr(), "%s : %s\n", (it->first).c_str(), (it->second).c_str() );
                ++it;
            }

            PerlIO_printf(PerlIO_stderr(), "\n");
        }
        #endif

        return result;
    }
};

MODULE = Text::KyTea    PACKAGE = Text::KyTea

PROTOTYPES: DISABLE

TextKyTea *
_init_text_kytea(char* CLASS, SV* args_ref)
    PREINIT:
        HV* hv           = (HV*)sv_2mortal((SV*)newHV());;
        SV* model_path_p = sv_newmortal();
    CODE:
        if ( !SvROK(args_ref) )
            croak("ref(hashref) expected");

        hv = (HV*)SvRV(args_ref);

        if (SvTYPE(hv) != SVt_PVHV)
            croak("hashref expected");

        model_path_p = *hv_fetchs(hv, "model_path", FALSE);

        TextKyTea* tkt = new TextKyTea();
        tkt->_init( SvPV_nolen(model_path_p) );

        RETVAL = tkt;
    OUTPUT:
        RETVAL

void
TextKyTea::_init(char* model_path)

vector< map<string, string> >
TextKyTea::parse(char* str)
