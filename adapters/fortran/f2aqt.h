void aqt_init__(void);
// ---
void aqt_open__(int *n);
void aqt_close__(void);
void aqt_render__(void);
void aqt_title__(char *title);
// ---
void aqt_use_color__(int *col);
void aqt_set_color__(int *col, float *r, float *g, float *b);
// ---
void aqt_linewidth__(float *width);
void aqt_line__(float *x1, float *y1, float *x2, float *y2);
void aqt_polygon__(float *x, float *y, int *n, int *isFilled);
void aqt_circle__(float *x, float *y, float *radius, int *isFilled);
// ---
void aqt_font__(char *fontname, float *size);
void aqt_textorient__(int *orient);
void aqt_textjust__(int *just);
void aqt_text__(float *x, float *y, const char *str);
// ---
void aqt_imagefromfile__(char *filename, float *x, float *y, float *w, float *h);
// ---
void aqt_get_size__(float *x_max, float *y_max);




