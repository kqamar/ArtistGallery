//
//  ArtistTableViewController.m
//  ArtistGallery
//
//  Created by Kashan Qamar on 9/17/15.
//  Copyright (c) 2015 AskNow Tech. All rights reserved.
//

#import "ArtistTableViewController.h"
#import "AppDelegate.h"
#import "ArtistEntity.h"
#import "ArtistCustomTableViewCell.h"
#import "ArtistDetailsTableViewController.h"



NSString *const urlPath = @"http://i.img.co/data/data.json";
#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)

@interface ArtistTableViewController ()

@property (nonatomic, strong) NSMutableData *responseData;

@property (nonatomic, strong) NSArray *artistGallery;
@property (nonatomic, strong) NSArray *savedData;


@end

@implementation ArtistTableViewController

NSDictionary *jsonDict;
NSURL *url;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = NSLocalizedString(@"My Artists", @"");
    
    
}

- (void) viewWillAppear:(BOOL)animated
{
    jsonDict = [[NSDictionary alloc] init];
   // self.episodes = [[NSArray alloc] init];
   // self.savedData = [[NSArray alloc] init];
    
    
    
    AppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
    self.managedObjectContext = appDelegate.managedObjectContext;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    //Setting Entity to be Queried
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"ArtistEntity"
                                              inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    NSError* error;
    
    // Query on managedObjectContext With Generated fetchRequest
    self.savedData = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    
    if([self.savedData count] == 0)
    {
        // Setup the URL with the JSON URL. This url is a copy of the IMDB.
        url = [NSURL URLWithString:urlPath];
        
        [self parseJSONWithURL:url];
    }
    else [self.tableView reloadData];
}


#pragma - parse method
// Parse the JSON data from the given URL
- (void) parseJSONWithURL:(NSURL *) jsonURL
{
    
    // Set the queue to the background queue. We will run this on the background thread to keep
    // the UI Responsive.
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    // Run request on background queue (thread).
    dispatch_async(queue, ^{
        NSError *error = nil;
        
        // Request the data and store in a string.
        NSString *json = [NSString stringWithContentsOfURL:jsonURL
                                                  encoding:NSUTF8StringEncoding
                                                     error:&error];
        
        if (error == nil){
            
            // Convert the String into an NSData object.
            NSData *jsonData = [json dataUsingEncoding:NSUTF8StringEncoding];
            
            // Parse that data object using NSJSONSerialization without options.
            jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];
            
            // Parsing success.
            if (error == nil)
            {
                // Go back to the main thread and update the table with the json data.
                // Keeps the user interface responsive.
                dispatch_async(dispatch_get_main_queue(), ^{
                    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
                    self.artistGallery = [jsonDict valueForKey:@"artists"];
                    
                    
                    
                    for(int i=0; i<self.artistGallery.count; i++)
                    {
                        ArtistEntity *newEntry = [NSEntityDescription insertNewObjectForEntityForName:@"ArtistEntity"
                                                                            inManagedObjectContext:self.managedObjectContext];
                        
                       // newEntry.id = [[self.artistGallery objectAtIndex:i] objectForKey:@"id"];
                        newEntry.genres = [[self.artistGallery objectAtIndex:i] objectForKey:@"genres"];
                        newEntry.picture = [[self.artistGallery objectAtIndex:i] objectForKey:@"picture"];
                        newEntry.name = [[self.artistGallery objectAtIndex:i] objectForKey:@"name"];
                        newEntry.descriptions = [[self.artistGallery objectAtIndex:i] objectForKey:@"description"];
                        NSError *error;
                        if (![self.managedObjectContext save:&error]) {
                            NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
                        }
                        
                    }
                    
                    [self.tableView reloadData];
                });
            }
            
            // Parsing failed, display error as alert.
            else
            {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error!" message:@"Uh Oh, Parsing Failed." delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
                
                [alertView show];
            }
        }
        
        // Request Failed, display error as alert.
        else
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error!" message:@"Request Error! Check that you are connected to wifi or 3G/4G with internet access." delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
            
            [alertView show];
        }
    });
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    if([self.savedData count] == 0)return self.artistGallery.count;
    else return self.savedData.count;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"ArtistDetailsSegue" sender:indexPath];
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    static NSString *CellIdentifier = @"ArtistCell";
    ArtistCustomTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    
    if([self.savedData count] == 0)
    {
        
        cell.artistName.text = [[self.artistGallery objectAtIndex:indexPath.row] objectForKey:@"name"];
        cell.genereNameLebl.text = [[self.artistGallery objectAtIndex:indexPath.row] objectForKey:@"genres"];
        
        
        cell.artImageView.image = nil; // or cell.poster.image = [UIImage imageNamed:@"placeholder.png"];
        
        dispatch_async(kBgQueue, ^{
            NSData *imgData = [NSData dataWithContentsOfURL:[[self.artistGallery objectAtIndex:indexPath.row] objectForKey:@"picture"]];
            if (imgData) {
                UIImage *image = [UIImage imageWithData:imgData];
                if (image) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        if (cell)
                            cell.artImageView.image = image;
                    });
                }
            }
        });

        
        
    }
    else{
        
        ArtistEntity * record = [self.savedData objectAtIndex:indexPath.row];
        cell.artistName.text = record.name;
        cell.genereNameLebl.text = record.genres;
        NSURL *url = [NSURL URLWithString:record.picture];

        
        dispatch_async(kBgQueue, ^{
            NSData *imgData = [NSData dataWithContentsOfURL:url];
            if (imgData) {
                UIImage *image = [UIImage imageWithData:imgData];
                if (image) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        if (cell)
                            cell.artImageView.image = image;
                    });
                }
            }
        });
        
    }
    
    return cell;
}




// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(NSIndexPath *)indexPath
{
    
    
}

@end
