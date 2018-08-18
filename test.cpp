#include <mex.h>

using namespace std;

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) {
    const mwSize *dims;
    mwIndex jcell;
    double *output;
    output = mxGetPr(prhs[0]);
    dims = mxGetDimensions(prhs[0]);
    for (jcell=0; jcell<dims[1]; jcell++) {
        printf("The content at %d is %f\n",jcell,output[jcell]);
    }
    return;
}
