void aqtInit(void);
// ---
void aqtOpenGraph(int n);
void aqtCloseGraph(void);
void aqtRenderGraph(void);
void aqtSetTitle(char *title);
// ---
void aqtUseColor(int col);
void aqtSetColormapEntry(int col, float r, float g, float b);
// ---
void aqtUseLinewidth(float width);
void aqtAddLine(float x1, float y1, float x2, float y2);
void aqtAddPolygon(float *x, float *y, int n, int isFilled);
void aqtAddCircle(float x, float y, float radius, int isFilled);
// ---
void aqtUseFont(char *fontname, float size);
void aqtUseTextOrientation(int orient);
void aqtUseTextJustification(int just);
void aqtAddText(float x, float y, const char *str);
// ---
void aqtAddImageFromFile(char *filename, float x, float y, float w, float h);
// ---
void aqtGetSize(float *x_max, float *y_max);




