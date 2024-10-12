package dinorun_pkg;

localparam int ScreenWidth = 640;
localparam int ScreenHeight = 480;

localparam int Ground = 400;
localparam int ObstacleInitialX = 640;

typedef enum logic [1:0] {
   // TODO
   TITLE_SCREEN,
   RUNNING,
   HIT
} state_t;

endpackage