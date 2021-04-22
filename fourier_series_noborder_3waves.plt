reset
set angle rad

#=================== Parameters ====================
center_x = -1.3*pi
center_y = 0

# Parameters in drawing
lineWidth = 2.0            # Line width
pointSize = 1.0
numPNG = 0
LOOP = 2

# Parameters in graph
numPlotArea = 3
incDegree = 2

# Color
array color[8] = [6, 2, 4, 1, 7, 3, 5, 8]
colorNo(i) = color[((i%8==0) ? 8 : (i%8))]
graphColor = "#b3000000" # W(x)'s line color, black(transparency 70)

#=================== Functions ====================
# Square wave
radius(i) = 4. / (pi*(2*i-1)) # Amplitude of i th sine curve
omega(i) = 2*(2*i-1) # Angle velocity
fourier(n, x) = sum[k=1:n] radius(k)*sin(omega(k)*x) # Fourier series
x(i, t) = center_x + ((i>1) ? (sum[k=1:i-1]radius(k)*cos(omega(k)*t)) : 0) # Position of the i th circle
y(i, t) = center_y + ((i>1) ? (sum[k=1:i-1]radius(k)*sin(omega(k)*t)) : 0)
# original(i, x) = (2*i*pi<=x && x<(2*i+1)*pi) ? 1 : (((2*i-1)*pi<=x && x<2*i*pi) ? -1 : 0)

# Triangle wave
# radius(i) = 12. / ((pi*(2*i-1))**2) # Amplitude of i th sine curve
# omega(i) = 2*(2*i-1) # Angle velocity
# fourier(n, x) = sum[k=1:n] radius(k)*cos(omega(k)*x) # Fourier series
# x(i, t) = center_x + ((i>1) ? (sum[k=1:i-1]radius(k)*sin(omega(k)*t)) : 0) # Position of the i th circle
# y(i, t) = center_y - ((i>1) ? (sum[k=1:i-1]radius(k)*cos(omega(k)*t)) : 0)
# original(i, x) = ((2*i-1)*pi<=x && x<(2*i+1)*pi) ? (3./2-3./pi*abs(x-2*pi*i)) : 0

# Sawtooth wave
# radius(i) = (3.*(-1)**(i+1)) / (pi*i)  # Amplitude of i th sine curve
# omega(i) = i # Angle velocity
# fourier(n, x) = sum[k=1:n] radius(k)*sin(2*omega(k)*x) # Fourier series
# x(i, t) = center_x - ((i>1) ? (sum[k=1:i-1]radius(k)*cos(2*omega(k)*t+omega(k)*pi)) : 0) # Position of the i th circle
# y(i, t) = center_y - ((i>1) ? (sum[k=1:i-1]radius(k)*sin(2*omega(k)*t+omega(k)*pi)) : 0)
# original(i, x) = ((2*i-1)*pi<=x && x<(2*i+1)*pi) ? (3./(2*pi) * (x-2*pi*i)): 0

wave(x) = sum[i=-LOOP:0] original(i, x)                    # Make original() the periodic function
F(n, x, t) = (x>=0 && x<=t) ? fourier(n, (x+pi/2)-t) : 1/0  # Translate fourier() and restrict the domain
W(x, t) = (x>=0 && x<=t) ? wave((x+pi)-t) : 1/0           # Translate wave() and restrict the domain

#=================== Plot ====================
# Setting
set term pngcairo truecolor enhanced dashed size 960, 360 font 'Times, 20'
system 'mkdir png_ending'
set size ratio -1
set samples 5000

do for [deg=0:360*LOOP:2] {
    t = deg * pi/180
    set output sprintf("png_ending/img_%04d.png", numPNG)
    numPNG = numPNG + 1

    do for [i=1:numPlotArea:1]{
        numFourier = 50

        unset key
        unset grid
        unset border

        set xr[2*center_x:pi]
        set yr[-3:3]

        unset xl
        unset yl
        # set xtics nomirror (0, pi, 2*pi, 3*pi, 4*pi, 5*pi, 6*pi) offset screen 0, 0.015 tc rgb 'white'
        # set ytics nomirror (-2, '' -1, 0, '' 1, 2) offset screen 0., 0 tc rgb 'white'
        # set tics lc rgb 'white'
        unset tics

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
        # plotCommand = plotCommand.sprintf(", W(x, t) lw %f lc rgb '%s'", lineWidth, graphColor)
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

    }

    set out  # Output PNG file
}
