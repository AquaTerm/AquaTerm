#include <stdio.h>
#include <aquaterm/aquaterm.h>

#define TRUE 1
#define FALSE 0

extern void aqtEventProcessingMode(void); // Not officially supported...

int decodeEvent(char *event);
void evth(int refNum, const char *event);

int running = TRUE;

int main(void)
{
   int i;
   char buffer[AQT_EVENTBUF_SIZE];

   aqtInit();
   aqtSetEventHandler(evth);
   aqtOpenPlot(1);
   aqtSetPlotSize(100.0, 200.0);
   aqtSetFontsize(18.0);
   aqtSetFontname("Verdana");
   aqtSetPlotTitle("Menu");
   // The menu
   aqtAddLabel("Menu", 50.0, 175.0, 0.0, AQTAlignCenter | AQTAlignMiddle);

   aqtSetColor(0.8, 0.8, 0.8);
   aqtAddFilledRect(10., 110., 80., 30.);
   aqtSetColor(1.0, 0.0, 0.0);
   aqtAddLabel("Red", 50.0, 125.0, 0.0, AQTAlignCenter | AQTAlignMiddle);

   aqtSetColor(0.8, 0.8, 0.8);
   aqtAddFilledRect(10., 60., 80., 30.);
   aqtSetColor(0.0, 0.0, 1.0);
   aqtAddLabel("Blue", 50.0, 75.0, 0.0, AQTAlignCenter | AQTAlignMiddle);

   aqtSetColor(0.8, 0.8, 0.8);
   aqtAddFilledRect(10., 10., 80., 30.);
   aqtSetColor(1.0, 1.0, 1.0);
   aqtAddLabel("Quit", 50.0, 25.0, 0.0, AQTAlignCenter | AQTAlignMiddle);

   aqtRenderPlot();
   aqtSetAcceptingEvents(TRUE);

   aqtOpenPlot(2);
   aqtSetPlotSize(400.0, 400.0);
   aqtSetPlotTitle("Display");

   while(running == TRUE)
   {
      printf("---> enter runLoop\n");
     aqtEventProcessingMode();
     printf("---> leving runLoop\n");
   }

   // Cleaning
   aqtSelectPlot(1);
   aqtClosePlot();
   aqtSelectPlot(2);
   aqtClosePlot();
   return 0;
}

void evth(int refNum, const char *event)
{
   printf("cli:%d evt:%s\n", refNum, event);
   switch (decodeEvent(event))
   {
      case 0: // Nil event
         printf("No action (ignoring)\n");
         break;
      case 1: // Red square
         aqtSelectPlot(2);
         aqtSetColor(1.0, 0.0, 0.0);
         aqtAddFilledRect(100., 100., 200., 200.);
         aqtRenderPlot();
         break;
      case 2: // Blue square
         aqtSelectPlot(2);
         aqtSetColor(0.0, 0.0, 1.0);
         aqtAddFilledRect(100., 100., 200., 200.);
         aqtRenderPlot();
         break;
      case 3: // Exit
         printf("Exit selected. Bye!\n");
         running = FALSE;
         break;
      case -1: // Error
         printf("Error, exiting\n");
         exit(1);
         break;
      default:
         printf("Que?\n");
         break;
   }
}


int decodeEvent(char *event)
{
   int x, y;
   char **ap, *argv[10];

   // Split arguments separated by a ':'
   for (ap = argv; (*ap = strsep(&event, ":")) != NULL;)
      if (**ap != '\0')
         if (++ap >= &argv[10])
            break;

   // Check for error in server
   if (strcmp(argv[0], "42") >= 0)
      return -1;

   // Only check for mouse clicks
   if (argv[0][0] != '1')
      return 0;

   // Decode position
   sscanf(argv[1], "{%d ,%d}", &x, &y);
   // printf("Clicked (%d, %d)\n", x, y);

   // Lazy, only test y-value:
   return 3-(y/50);
}

