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
#include <string>
#include <utility> // pair
#include "kytea/kytea.h"
#include "kytea/kytea-struct.h"
using namespace std;
using namespace kytea;

struct TextKyTeaRet
{
    vector<string> surface;
    vector< vector< vector< pair<string, double> > > > tags;
};

class TextKyTea
{
private:
    Kytea kytea;
    StringUtil*  util;
    KyteaConfig* config;
    TextKyTeaRet result;
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
    TextKyTeaRet* parse(const char* str)
    {
        result.surface.clear();
        result.tags.clear();

        KyteaSentence sentence(util->mapString(str));
        kytea.calculateWS(sentence);

        for (int i = 0; i < config->getNumTags(); ++i)
            kytea.calculateTags(sentence,i);

        const KyteaSentence::Words & words = sentence.words;

        for (int i = 0; i < (int)words.size(); ++i)
        {
            result.surface.push_back( util->showString(words[i].surf) );

            #ifdef TEXT_KYTEA_DEBUG
            PerlIO_printf( PerlIO_stderr(), "%s", result.surface[i].c_str() );
            #endif

            vector< vector< pair<string, double> > > result_tags;

            for(int j = 0; j < (int)words[i].tags.size(); ++j)
            {
                #ifdef TEXT_KYTEA_DEBUG
                PerlIO_printf(PerlIO_stderr(), "\t");
                #endif

                vector< pair<string, double> > result_tag_pairs;

                for (int k = 0; k < (int)words[i].tags[j].size(); ++k)
                {
                    string tag   = util->showString(words[i].tags[j][k].first);
                    double score = words[i].tags[j][k].second;

                    result_tag_pairs.push_back( pair<string, double>(tag, score) );

                    #ifdef TEXT_KYTEA_DEBUG
                    PerlIO_printf( PerlIO_stderr(), " %s", tag.c_str() );
                    PerlIO_printf(PerlIO_stderr(), "/%f", score);
                    #endif
                }

                result_tags.push_back(result_tag_pairs);

                #ifdef TEXT_KYTEA_DEBUG
                PerlIO_printf(PerlIO_stderr(), "\t");
                #endif
            }

            result.tags.push_back(result_tags);

            #ifdef TEXT_KYTEA_DEBUG
            PerlIO_printf(PerlIO_stderr(), "\n");
            #endif
        }

        return &result;
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
TextKyTea::_init(const char* model_path)

void
TextKyTea::read_model(const char* model_path)

TextKyTeaRet*
TextKyTea::parse(const char* str)
