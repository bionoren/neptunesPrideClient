//
//  MainViewController+loadData.m
//  NeptunesPride
//
//  Created by Bion Oren on 4/19/13.
//  Copyright (c) 2013 Bion Oren. All rights reserved.
//

#import "MainViewController+loadData.h"
#import "AppDelegate.h"
#import "Player+Helpers.h"
#import "Star.h"
#import "Fleet.h"
#import "NSManagedObject+Helpers.h"

@implementation MainViewController (loadData)

-(void)loadData {
    //curl "http://triton.ironhelmet.com/grequest/order" --data "type=order&order=full_universe_report&game_number=1429278"
    NSMutableURLRequest *request =[NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://triton.ironhelmet.com/grequest/order"]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"__utma=110446173.1320838023.1366223391.1366223391.1366223391.1; __utmc=110446173; __utmz=110446173.1366223391.1.1.utmcsr=(direct)|utmccn=(direct)|utmcmd=(none); __utma=127647816.971439499.1366203781.1366431660.1366466572.16; __utmb=127647816.1.10.1366466572; __utmc=127647816; __utmz=127647816.1366203781.1.1.utmcsr=facebook.com|utmccn=(referral)|utmcmd=referral|utmcct=/l/DAQF7Qu1QAQHFeN7yQSqmnJ2a5uaW4jxkNLFW4l95C-xpRg/triton.ironhelmet.com/game/1429278; ACSID=AJKiYcGndfDsjczWFw-YPwG64Gh2JJRvISFOgyShzlxiqSecVKeVEjQnhgQgz_O8Rc_AKNS0M1soLhA8vnzDmzkEj0BLdUWSHT2d-Y2SYOEUO9gjYV-XDlKIjp-HzJ21PQEzrjwnoXzGTxZSCTplgj283QyhO6IkL4Bv44oVcQbvEveSNY-YI_9Hkc9ZEXjBje3tVj49755G7ffO2i2pSMkC9rSaRMS7_GsqdULW0yp30QKnKtHcG9obcKFZBbhKfmyJO3sEH2CzsI5kgVZbv44L75E595ioOKMzTM4HG8N5BqEWAUEQzp3c74CarBGjG38fWzzXPKgyPdRlcZfaAorzebhWtRK0JiO_aMJaMGsH2boHocM6u7Fw3sCSODn8P_CxtwxfClfZTz0uqqDx9f2uRYz9YIDriNmwgjkOwxZMzwGz3FI8tmT-17esYqAwzeaGIcipMeS0ccRONe-0FfnUJIdeVEErNVJup_R244y1MBII6GqAv5P6mXk6cC5ZSXHWjKmTlMoEWRF8Jb8NkxIIwh4LZnsfQJ5-mh2NJMW2ryG5n_Flw7E" forHTTPHeaderField:@"Cookie"];

    NSString *post =[NSString stringWithFormat:@"type=order&order=full_universe_report&game_number=%d", 1429278];
    [request setHTTPBody:[post dataUsingEncoding:NSUTF8StringEncoding]];

    NSURLResponse *response;
    NSError *err = nil;
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&err];
    if(err) {
        NSLog(@"ERROR: %@", err);
    }

    err = nil;
    NSDictionary *data = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&err][@"report"];
    NSLog(@"Data = %@", data);

    [Player deleteAllObjects];
    [Star deleteAllObjects];
    [Fleet deleteAllObjects];

    //players
    for(NSDictionary *player in [data[@"players"] objectEnumerator]) {
        Player *p = [NSEntityDescription insertNewObjectForEntityForName:@"Player" inManagedObjectContext:GET_CONTEXT];
        p.uid = @([player[@"uid"] intValue]);
        p.name = player[@"alias"];
        p.economy = @([player[@"total_economy"] intValue]);
        p.industry = @([player[@"total_industry"] intValue]);
        p.science = @([player[@"total_science"] intValue]);
        p.strength = @([player[@"total_strength"] intValue]);
        p.numFleets = @([player[@"total_fleets"] intValue]);
        NSAssert(p.name, @"Need a name: %@", player);
    }
    Player *noPlayer = [NSEntityDescription insertNewObjectForEntityForName:@"Player" inManagedObjectContext:GET_CONTEXT];
    noPlayer.uid = @(-1);
    noPlayer.name = @"Nobody";
    SAVE_CONTEXT;

    //stars
    for(NSDictionary *star in [data[@"stars"] objectEnumerator]) {
        Star *s = [NSEntityDescription insertNewObjectForEntityForName:@"Star" inManagedObjectContext:GET_CONTEXT];
        s.name = star[@"n"];
        s.x = @([star[@"x"] floatValue]);
        s.y = @([star[@"y"] floatValue]);
        s.uid = @([star[@"uid"] intValue]);
        int player = [star[@"puid"] intValue];
        s.player = [Player playerFromUID:player];
        if([star[@"v"] boolValue]) {
            s.economy = @([star[@"e"] intValue]);
            s.industry = @([star[@"i"] intValue]);
            s.science = @([star[@"s"] intValue]);
            s.garrison = @([star[@"g"] intValue]);
            s.naturalResources = @([star[@"nr"] intValue]);
            s.resources = @([star[@"r"] intValue]);
            s.buildRate = @([star[@"c"] floatValue]);
            s.ships = @([star[@"st"] intValue]);
        }
    }
    SAVE_CONTEXT;

    //fleets
    for(NSDictionary *fleet in [data[@"fleets"] objectEnumerator]) {
        Fleet *f = [NSEntityDescription insertNewObjectForEntityForName:@"Fleet" inManagedObjectContext:GET_CONTEXT];
        f.name = fleet[@"n"];
        int player = [fleet[@"puid"] intValue];
        f.player = [Player playerFromUID:player];
        f.strength = @([fleet[@"st"] intValue]);
        f.uid = @([fleet[@"uid"] intValue]);
        f.x = @([fleet[@"x"] floatValue]);
        f.y = @([fleet[@"y"] floatValue]);
    }
    SAVE_CONTEXT;
}

@end