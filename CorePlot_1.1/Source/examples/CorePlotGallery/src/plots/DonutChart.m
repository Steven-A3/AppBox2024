#import "DonutChart.h"

NSString *const innerChartName = @"Inner";
NSString *const outerChartName = @"Outer";

@implementation DonutChart

+(void)load
{
    [super registerPlotItem:self];
}

-(id)init
{
    if ( (self = [super init]) ) {
        title = @"Donut Chart";
    }

    return self;
}

-(void)killGraph
{
    [super killGraph];
}

-(void)dealloc
{
    [plotData release];
    [super dealloc];
}

-(void)generateData
{
    if ( plotData == nil ) {
        plotData = [[NSMutableArray alloc] initWithObjects:
                    [NSNumber numberWithDouble:20.0],
                    [NSNumber numberWithDouble:30.0],
                    [NSNumber numberWithDouble:60.0],
                    nil];
    }
}

-(void)renderInLayer:(CPTGraphHostingView *)layerHostingView withTheme:(CPTTheme *)theme
{
#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
    CGRect bounds = layerHostingView.bounds;
#else
    CGRect bounds = NSRectToCGRect(layerHostingView.bounds);
#endif

    CPTGraph *graph = [[[CPTXYGraph alloc] initWithFrame:bounds] autorelease];
    [self addGraph:graph toHostingView:layerHostingView];
    [self applyTheme:theme toGraph:graph withDefault:[CPTTheme themeNamed:kCPTPlainWhiteTheme]];

    graph.title = title;
    CPTMutableTextStyle *textStyle = [CPTMutableTextStyle textStyle];
    textStyle.color                = [CPTColor grayColor];
    textStyle.fontName             = @"Helvetica-Bold";
    textStyle.fontSize             = bounds.size.height / 20.0f;
    graph.titleTextStyle           = textStyle;
    graph.titleDisplacement        = CGPointMake(0.0f, bounds.size.height / 18.0f);
    graph.titlePlotAreaFrameAnchor = CPTRectAnchorTop;

    graph.plotAreaFrame.masksToBorder = NO;

    // Graph padding
    float boundsPadding = bounds.size.width / 20.0f;
    graph.paddingLeft   = boundsPadding;
    graph.paddingTop    = graph.titleDisplacement.y * 2;
    graph.paddingRight  = boundsPadding;
    graph.paddingBottom = boundsPadding;

    graph.axisSet = nil;

    CPTMutableLineStyle *whiteLineStyle = [CPTMutableLineStyle lineStyle];
    whiteLineStyle.lineColor = [CPTColor whiteColor];

    CPTMutableShadow *whiteShadow = [CPTMutableShadow shadow];
    whiteShadow.shadowOffset     = CGSizeMake(0.0, -13.0);
    whiteShadow.shadowBlurRadius = 3.0;
    whiteShadow.shadowColor      = [[CPTColor darkGrayColor] colorWithAlphaComponent:0.25];

    // Add pie chart
    CPTPieChart *piePlot = [[CPTPieChart alloc] init];
    piePlot.dataSource = self;
    piePlot.pieRadius  = MIN(0.7 * (layerHostingView.frame.size.height - 2 * graph.paddingLeft) / 2.0,
                             0.7 * (layerHostingView.frame.size.width - 2 * graph.paddingTop) / 2.0);
    CGFloat innerRadius = piePlot.pieRadius / 2.0;
    piePlot.pieInnerRadius  = innerRadius + 5.0;
    piePlot.identifier      = outerChartName;
    piePlot.borderLineStyle = whiteLineStyle;
    piePlot.startAngle      = M_PI_4;
    piePlot.endAngle        = 3.0 * M_PI_4;
    piePlot.sliceDirection  = CPTPieDirectionCounterClockwise;
    piePlot.shadow          = whiteShadow;
    piePlot.labelOffset     = -60.0f;
    piePlot.delegate        = self;
    [graph addPlot:piePlot];
    [piePlot release];

    // Overlay gradient for pie chart
    CPTGradient *overlayGradient = [[[CPTGradient alloc] init] autorelease];
    overlayGradient.gradientType = CPTGradientTypeRadial;
    overlayGradient              = [overlayGradient addColorStop:[[CPTColor blackColor] colorWithAlphaComponent:0.0] atPosition:0.0];
    overlayGradient              = [overlayGradient addColorStop:[[CPTColor blackColor] colorWithAlphaComponent:0.2] atPosition:1.0];

    // Add another pie chart
    piePlot                 = [[CPTPieChart alloc] init];
    piePlot.dataSource      = self;
    piePlot.pieRadius       = innerRadius - 5.0;
    piePlot.pieInnerRadius  = 35.0f;
    piePlot.identifier      = innerChartName;
    piePlot.borderLineStyle = whiteLineStyle;
    piePlot.startAngle      = 4 * M_PI_4;
    piePlot.sliceDirection  = CPTPieDirectionClockwise;
    piePlot.shadow          = whiteShadow;
    piePlot.overlayFill    = [CPTFill fillWithGradient:overlayGradient];
    piePlot.delegate        = self;
    [graph addPlot:piePlot];
    [piePlot release];
}

-(void)pieChart:(CPTPieChart *)plot sliceWasSelectedAtRecordIndex:(NSUInteger)index
{
    NSLog(@"%@ slice was selected at index %lu. Value = %@", plot.identifier, (unsigned long)index, [plotData objectAtIndex:index]);
}

#pragma mark -
#pragma mark Plot Data Source Methods

-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot
{
    return [plotData count];
}

-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index
{
    NSNumber *num;

    if ( fieldEnum == CPTPieChartFieldSliceWidth ) {
        num = [plotData objectAtIndex:index];
    }
    else {
        return [NSNumber numberWithInt:index];
    }

    return num;
}

-(CPTLayer *)dataLabelForPlot:(CPTPlot *)plot recordIndex:(NSUInteger)index
{
    static CPTMutableTextStyle *whiteText = nil;

    CPTTextLayer *newLayer = nil;

    if ( [(NSString *)plot.identifier isEqualToString:outerChartName] ) {
        if ( !whiteText ) {
            whiteText       = [[CPTMutableTextStyle alloc] init];
            whiteText.color = [CPTColor whiteColor];
        }

        newLayer                 = [[[CPTTextLayer alloc] initWithText:[NSString stringWithFormat:@"%.0f", [[plotData objectAtIndex:index] floatValue]] style:whiteText] autorelease];
        newLayer.fill            = [CPTFill fillWithColor:[CPTColor darkGrayColor]];
        newLayer.cornerRadius    = 5.0;
        newLayer.paddingLeft     = 3.0;
        newLayer.paddingTop      = 3.0;
        newLayer.paddingRight    = 3.0;
        newLayer.paddingBottom   = 3.0;
        newLayer.borderLineStyle = [CPTLineStyle lineStyle];
    }

    return newLayer;
}

-(CGFloat)radialOffsetForPieChart:(CPTPieChart *)pieChart recordIndex:(NSUInteger)index
{
    CGFloat result = 0.0;

    if ( [(NSString *)pieChart.identifier isEqualToString:outerChartName] ) {
        result = (index == 0 ? 15.0 : 0.0);
    }
    return result;
}

-(CPTFill *)sliceFillForPieChart:(CPTPieChart *)pieChart recordIndex:(NSUInteger)idx {
    NSLog(@"%s", __FUNCTION__);
    CPTFill *fill = nil;
    if (idx == 0) {
        CPTColor *beginningColor = [CPTColor colorWithComponentRed:255.0/255.0f green:200.0f/255.0f blue:105.0f/255.0f alpha:1.0f];
        CPTColor *endingColor = [CPTColor colorWithComponentRed:255.0f/255.0f green:223.0f/255.0f blue:161.0f/255.0f alpha:1.0f];
        CPTGradient *gradient = [CPTGradient gradientWithBeginningColor:beginningColor endingColor:endingColor];
//        gradient.gradientType = CPTGradientTypeRadial;
        fill = [[CPTFill alloc] initWithGradient:gradient];
    }
    return fill;
}

@end
