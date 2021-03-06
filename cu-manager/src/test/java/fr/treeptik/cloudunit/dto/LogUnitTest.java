/*
 * LICENCE : CloudUnit is available under the Affero Gnu Public License GPL V3 : https://www.gnu.org/licenses/agpl-3.0.html
 * but CloudUnit is licensed too under a standard commercial license.
 * Please contact our sales team if you would like to discuss the specifics of our Enterprise license.
 * If you are not sure whether the GPL is right for you,
 * you can always test our software under the GPL and inspect the source code before you contact us
 * about purchasing a commercial license.
 *
 * LEGAL TERMS : "CloudUnit" is a registered trademark of Treeptik and can't be used to endorse
 * or promote products derived from this project without prior written permission from Treeptik.
 * Products or services derived from this software may not be called "CloudUnit"
 * nor may "Treeptik" or similar confusing terms appear in their names without prior written permission.
 * For any questions, contact us : contact@treeptik.fr
 */

package fr.treeptik.cloudunit.dto;

import org.junit.FixMethodOrder;
import org.junit.Test;
import org.junit.runners.MethodSorters;

import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertTrue;

/**
 * Created by nicolas on 30/09/15.
 */
@FixMethodOrder(MethodSorters.NAME_ASCENDING)
public class LogUnitTest {

    @Test(expected = IllegalArgumentException.class)
    public void parameterNotNullorEmpty() {
        LogUnit line1 = new LogUnit(null, "02-10-2015 11:02:25", "Hello, I am a log stackstrace!");
    }

    @Test
    public void differentsLinesForMessage() {
        LogUnit line1 = new LogUnit("catalina.out", "02-10-2015 11:02:25", "Hello, I am a log stackstrace!");
        LogUnit line2 = new LogUnit("catalina.out", "02-10-2015 11:02:25", "Hello, I am an another message!");
        assertFalse(line1.equals(line2));
    }

    @Test
    public void differentsLinesForSources() {
        LogUnit line1 = new LogUnit("catalina.out", "02-10-2015 11:02:25", "Hello, I am a log stackstrace!");
        LogUnit line2 = new LogUnit("localhost.txt", "02-10-2015 11:02:25", "Hello, I am a log stackstrace!");
        assertFalse(line1.equals(line2));

        line1 = new LogUnit("catalina.out", "", "Hello, I am a log stackstrace!");
        line2 = new LogUnit("", "02-10-2015 11:02:25", "Hello, I am a log stackstrace!");
        assertFalse(line1.equals(line2));

        assertFalse(line1.equals(line2));
    }

    @Test
    public void differentsLinesForDates() {
        LogUnit line1 = new LogUnit("catalina.out", "19-09-2014 12:03:24", "Hello, I am a log stackstrace!");
        LogUnit line2 = new LogUnit("localhost.txt", "02-10-2015 11:02:25", "Hello, I am a log stackstrace!");
        assertFalse(line1.equals(line2));
    }

    @Test
    public void equalsLines() {
        LogUnit line1 = new LogUnit("catalina.out", "02-10-2015 11:02:25", "Hello, I am a log stackstrace!");
        LogUnit line2 = new LogUnit("catalina.out", "02-10-2015 11:02:25", "Hello, I am a log stackstrace!");
        assertTrue(line1.equals(line2));
    }

}