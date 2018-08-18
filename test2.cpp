#include "mex.h"
#include "string.h"

using namespace std;

void printArray(char charArray[]) {
    int itr;
    int len = strlen(charArray);
    mexPrintf("The value of C array is %s\n", charArray);
}

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) {
    const mxArray *cell_element_ptr;
    char* c_array;
    mwIndex i;
    mwSize total_num_of_cells, buflen;
    int status;
    /*Extract the cotents of MATLAB cell into the C array*/
   total_num_of_cells = mxGetNumberOfElements(prhs[0]);
   for(i=0;i<total_num_of_cells;i++){
       cell_element_ptr = mxGetCell(prhs[0],i);
       buflen = mxGetN(cell_element_ptr)*sizeof(mxChar)+1;
       c_array = (char*)mxMalloc(buflen);
       status = mxGetString(cell_element_ptr,c_array,buflen);
       printArray(c_array);
       mxFree(c_array);
    }
    mexPrintf("Success\n");
}
