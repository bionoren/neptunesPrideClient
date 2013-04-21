//
//  NSManagedObject+Helpers.m
//  NeptunesPride
//
//  Created by Bion Oren on 4/20/13.
//  Copyright (c) 2013 Bion Oren. All rights reserved.
//

#import "NSManagedObject+Helpers.h"
#import "AppDelegate.h"
#import "Player+Helpers.h"
#import "Star.h"
#import "Fleet.h"
#import "Research.h"

@implementation NSManagedObject (Helpers)

+(void)deleteAllObjects {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:NSStringFromClass([self class]) inManagedObjectContext:GET_CONTEXT];
    [fetchRequest setEntity:entity];

    NSError *err = nil;
    NSArray *items = [GET_CONTEXT executeFetchRequest:fetchRequest error:&err];
    if(err) {
        NSLog(@"ERROR: %@", err);
    }


    for (NSManagedObject *obj in items) {
    	[GET_CONTEXT deleteObject:obj];
    }
    SAVE_CONTEXT;
}

+(Report*)loadData {
    //curl "http://triton.ironhelmet.com/grequest/order" --data "type=order&order=full_universe_report&game_number=1429278"
    NSMutableURLRequest *request =[NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://triton.ironhelmet.com/grequest/order"]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"__utma=110446173.1320838023.1366223391.1366223391.1366223391.1; __utmc=110446173; __utmz=110446173.1366223391.1.1.utmcsr=(direct)|utmccn=(direct)|utmcmd=(none); __utma=127647816.971439499.1366203781.1366516430.1366549243.26; __utmc=127647816; __utmz=127647816.1366203781.1.1.utmcsr=facebook.com|utmccn=(referral)|utmcmd=referral|utmcct=/l/DAQF7Qu1QAQHFeN7yQSqmnJ2a5uaW4jxkNLFW4l95C-xpRg/triton.ironhelmet.com/game/1429278; ACSID=AJKiYcFZCGsjHGK1OfN2WG2LDk3mT6smOsyF8-kZ0zQXnciEzy8a0HhdMwwcban3GArCrvCAHp5mrqzwrmILYTtFOSXily3CiHjMJ-cTnu2UOji8V-Xc9QA6mehp2Zg5zJlkGeArwdmrOK8-QlBP5rCFmmZwRQTjmHlxjet15xmCBHS00fGDEp9dJuVmakIoV1UyilBIN8QS1NnmyWfQ75o4pntPrdh04-g0ZUS29Yez1gmRhAaJ4VPg1GZB_M28VQIcRqslqFxNFECaZ0PsiW1JsPqbZNutEfnkcwWietx5qn7dRCljVqKLdMiwh6F8ZS4eV8ElPOQFLDKjYP56u4bhWMqz9NeeYeiARSNnCouSz-NVeij8dLncaiMedFFcnjzILXqmdj-Czs88X8fHcPKL1U-gSz0iyNJmOfklvsgoaASGimGlrdzj3W6N2H1S9w2hZiyDx6CFGnLOpH6tjkEDkh4LXhwrgNXBTBB-fCrwnZJErjg0MLV-vPaUD6Zcok5SwHWiLxElEVdOsd6wjMz96ed3Gk9Yf8rmQ3EWUck-T0xqPPtjQTI" forHTTPHeaderField:@"Cookie"];

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
    //NSLog(@"Data = %@", data);

    //[Report deleteAllObjects];

    //report
    Report *report = [NSEntityDescription insertNewObjectForEntityForName:@"Report" inManagedObjectContext:GET_CONTEXT];
    report.collectionTime = [NSDate date];
    report.gameTime = [NSDate dateWithTimeIntervalSince1970:[data[@"now"] longValue] / 1000];
    report.originatorUID = @([data[@"player_uid"] intValue]);
    report.tick = @([data[@"tick"] intValue]);
    report.tick_fragment = @([data[@"tick_fragment"] floatValue]);
    SAVE_CONTEXT;

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
        p.report = report;
        p.cash = @([player[@"cash"] intValue]);
        NSAssert(p.name, @"Need a name: %@", player);
        SAVE_CONTEXT;

        //research
        for(NSString *name in [player[@"tech"] keyEnumerator]) {
            NSDictionary *research = player[@"tech"][name];
            Research *r = [NSEntityDescription insertNewObjectForEntityForName:@"Research" inManagedObjectContext:GET_CONTEXT];
            r.name = name;
            r.player = p;
            r.level = @([research[@"level"] intValue]);
            r.value = @([research[@"value"] floatValue]);
            if(player[@"cash"]) { //this is us
                /*
                 There are two values "bv" and "sv" in the JSON that are not well understood.
                 bv is 1 and sv is 0 for every research but propulsion and scanning. Also, neither changes for weapons when weapons is researched
                 Initially, it is true that "bv + sv = value", but the weapons data forces us to re-evaluate this to "bv * level + sv = value"
                 This would mean that "sv" is a "base value" and "bv" is the "research increment"
                 */
                r.increment = @([research[@"bv"] floatValue]);
                r.goal = @([research[@"brr"] intValue]); //this doesn't get incremented in the JSON
                r.progress = @([research[@"research"] intValue]);
            }
        }
        SAVE_CONTEXT;
    }
    Player *noPlayer = [NSEntityDescription insertNewObjectForEntityForName:@"Player" inManagedObjectContext:GET_CONTEXT];
    noPlayer.uid = @(-1);
    noPlayer.name = @"Nobody";
    noPlayer.report = report;
    SAVE_CONTEXT;

    //stars
    for(NSDictionary *star in [data[@"stars"] objectEnumerator]) {
        Star *s = [NSEntityDescription insertNewObjectForEntityForName:@"Star" inManagedObjectContext:GET_CONTEXT];
        s.name = star[@"n"];
        s.x = @([star[@"x"] floatValue]);
        s.y = @([star[@"y"] floatValue]);
        s.uid = @([star[@"uid"] intValue]);
        int player = [star[@"puid"] intValue];
        s.player = [Player playerFromUID:player inReport:report];
        s.visible = @([star[@"v"] boolValue]);
        if(s.visible) {
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
        f.player = [Player playerFromUID:player inReport:report];
        f.strength = @([fleet[@"st"] intValue]);
        f.uid = @([fleet[@"uid"] intValue]);
        f.x = @([fleet[@"x"] floatValue]);
        f.y = @([fleet[@"y"] floatValue]);
    }
    SAVE_CONTEXT;

    [Report setLatestReport:report];
    
    double delayInSeconds = 1.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadData" object:nil userInfo:@{@"report": report}];
    });

    return report;
}

@end