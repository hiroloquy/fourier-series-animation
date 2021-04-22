reset
set angle rad

#=================== Parameters ====================
center_x = -1.3*pi
center_y = 0

# Parameters in drawing
lineWidth = 2.0
pointSize = 1.0
numPNG = 0
LOOP = 4

# Parameters in graph
numPlotArea = 3
incDegree = 2
graphHeight = 0.22
axisHeight = 0.09
offsetHeight = 0.02
marginHeight = (1.0-(numPlotArea*graphHeight+axisHeight+offsetHeight))/3
leftMargin = 0.21

# Color
array color[8] = [6, 2, 4, 1, 7, 3, 5, 8]
colorNo(i) = color[((i%8==0) ? 8 : (i%8))]
graphColor = "#b3000000" # W(x)'s line color, black(transparency 70)

#=================== Functions ====================
# Sawtooth wave
radius(i) = (3.*(-1)**(i+1)) / (pi*i)  # Amplitude of i th sine curve
omega(i) = i # Angle velocity
fourier(n, x) = sum[k=1:n] radius(k)*sin(omega(k)*x) # Fourier series
x(i, t) = center_x - ((i>1) ? (sum[k=1:i-1]radius(k)*cos(omega(k)*(t+pi))) : 0) # Position of the i th circle
y(i, t) = center_y - ((i>1) ? (sum[k=1:i-1]radius(k)*sin(omega(k)*(t+pi))) : 0)
original(i, x) = ((2*i-1)*pi<=x && x<(2*i+1)*pi) ? (3./(2*pi) * (x-2*pi*i)): 0

wave(x) = sum[i=-LOOP:0] original(i, x)                   # Make original() the periodic function
F(n, x, t) = (x>=0 && x<=t) ? fourier(n, (x+pi)-t) : 1/0  # Translate fourier() and restrict the domain
W(x, t) = (x>=0 && x<=t) ? wave((x+pi)-t) : 1/0           # Translate wave() and restrict the domain

#=================== Plot ====================
# Setting
set term pngcairo truecolor enhanced dashed size 1080, 720 font 'Times, 20'
system 'mkdir png'
set size ratio -1
set samples 5000

do for [deg=0:360*LOOP:2] {
  t = deg * pi/180
  set output sprintf("png/img_%04d.png", numPNG)
  numPNG = numPNG + 1

  set multiplot
  do for [i=1:numPlotArea:1]{
    numFourier = incDegree*((1+numPlotArea)-i)-1 # n=1, 3, 5
    # numFourier = 10*((1+numPlotArea)-i) # n=10, 20, 30

    # Common setting
    bottomGraphY = axisHeight+(i-1)*(graphHeight+marginHeight) + offsetHeight
    topGraphY = (axisHeight+graphHeight) + (i-1)*(marginHeight+graphHeight) + offsetHeight

    # Set the position and size of the graph
    set lmargin screen leftMargin
    set bmargin screen bottomGraphY
    set tmargin screen topGraphY

    centerGraphY = (bottomGraphY+topGraphY)/2
    set label 1 left sprintf('{/:Italic n} = %d', numFourier) at screen 0.04, centerGraphY font ', 22'

    unset key
    set grid
    set xr[2*center_x:4*pi]
    set yr[-2:2]
    unset xl
    set yl '{/:Italic y}' offset screen 0, 0
    set xtics nomirror (0, pi, 2*pi, 3*pi, 4*pi, 5*pi, 6*pi) offset screen 0, 0.015 tc rgb 'white' # Draw only tic marks
    set ytics nomirror (-2, '' -1, 0, '' 1, 2) offset screen 0., 0

    if(i==1){
      set xl '{/:Italic x}' offset screen 0, 0.02
      set xtics nomirror (0, '{/:Italic π}' pi, '2{/:Italic π}' 2*pi, '3{/:Italic π}' 3*pi, \
      '4{/:Italic π}' 4*pi, '5{/:Italic π}' 5*pi, '6{/:Italic π}' 6*pi) tc rgb 'black'
    }

    # Draw circles and arrows without head representing circle's rotation
    do for [j=1:numFourier]{
      set object j circle at x(j, t), y(j, t) size abs(radius(j)) fs empty border lt colorNo(j) lw lineWidth front
      set arrow j nohead from x(j, t), y(j, t) to x(j+1, t), y(j+1, t) lw lineWidth lt colorNo(j) back
    }

    # Draw the line connected between the numFourier th circle and the graph F(x)
    set arrow numFourier+1 nohead from x(numFourier+1, t), y(numFourier+1, t) to 0, y(numFourier+1, t) lw lineWidth lt colorNo(numFourier) front #lc rgb auxColor front

    # Plot function F() and W(), and draw the points representing the center of the circle
    plotCommand = sprintf("plot F(numFourier, x, t) lw %f lt %d", lineWidth, colorNo(numFourier))
    plotCommand = plotCommand.sprintf(", \"<echo '%.2f, %.2f'\" w p pt 7 ps %d lt %d", 0, y(numFourier+1, t), pointSize, colorNo(numFourier))
    plotCommand = plotCommand.sprintf(", W(x, t) lw %f lc rgb '%s'", lineWidth, graphColor)
    end = ((numFourier>3)?3:numFourier)
    do for [j=1:end]{
      plotCommand = plotCommand.sprintf(", \"<echo '%.2f, %.2f'\" w p pt 7 ps %d lt %d", x(j+1, t), y(j+1, t), pointSize, colorNo(j))
    }

    eval plotCommand

    # Unset objects and arrows in order not to display them in the other plot area
    do for [j=1:numFourier]{
      unset object j
      unset arrow j
    }
    unset arrow numFourier+1
    unset label 1

  }
  unset multiplot

  set out  # Output PNG file
}
