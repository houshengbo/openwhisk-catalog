package packages.samples

import java.io.File
import org.junit.runner.RunWith
import org.scalatest.junit.JUnitRunner
import scala.concurrent.duration.DurationInt
import scala.language.postfixOps
import org.junit.Assert.assertTrue

import common.JsHelpers
import common.TestHelpers
import common.Wsk
import common.WskProps
import common.WskTestHelpers
import spray.json.DefaultJsonProtocol.BooleanJsonFormat
import spray.json.DefaultJsonProtocol.StringJsonFormat
import spray.json.pimpAny

@RunWith(classOf[JUnitRunner])
class WordCountTest extends TestHelpers
    with WskTestHelpers
    with JsHelpers {

    implicit val wskprops = WskProps()
    val wsk = new Wsk(usePythonCLI=true)
    val wordcountAction = "/whisk.system/samples/wordCount"
    var catalogDir = new File(scala.util.Properties.userDir.toString(), "../packages")
    val sample_file = "samples/wordcount/javascript/wordcount.js"

    behavior of "samples wordCount"

    it should "Return the number of words when sending the words as payload" in withAssetCleaner(wskprops) {
        (wp, assetHelper) =>
            val expectedNumber = 3
            val run = wsk.action.invoke(wordcountAction,
                Map("payload" -> "Five fuzzy felines".toJson))
            withActivation(wsk.activation, run) {
                activation =>
                    activation.getFieldPath("response", "success") should be(Some(true.toJson))
                    activation.getFieldPath("response", "result", "count").toString should be(
                        Some(expectedNumber).toString)
            }
    }

    it should "Return an error has occurred: TypeError: Cannot read property 'toString' of undefined " +
        "failure when sending no payload" in withAssetCleaner(wskprops) {
        (wp, assetHelper) =>
            val expectedError = "An error has occurred: TypeError: Cannot read property 'toString' of undefined".toJson
            val run = wsk.action.invoke(wordcountAction, Map())
            withActivation(wsk.activation, run) {
                activation =>
                    activation.getFieldPath("response", "success") should be(Some(false.toJson))
                    activation.getFieldPath("response", "result", "error") should be(
                        Some(expectedError))
            }
    }

    it should "Create an action, then return the number of words when sending the words as payload on Nodejs" in withAssetCleaner(wskprops) {
        (wp, assetHelper) =>
            val name = "wcNodejs"
            val file = new File(catalogDir, sample_file).toString()
     
            assetHelper.withCleaner(wsk.action, name) {
                (action, _) => action.create(name, Some(file), kind = Some("nodejs"))
            }
            wsk.action.get(name).stdout should include regex (""""kind": "nodejs"""")
 
            val run = wsk.action.invoke(name, Map("payload" -> "Five fuzzy felines".toJson))
            val expectedNumber = 3
            withActivation(wsk.activation, run) {
                activation =>
                    activation.getFieldPath("response", "success") should be(Some(true.toJson))
                    activation.getFieldPath("response", "result", "count").toString should be(
                        Some(expectedNumber).toString)
            }
    }

    it should "Create an action, then return the number of words when sending the words as payload on Nodejs 6" in withAssetCleaner(wskprops) {
        (wp, assetHelper) =>
            val name = "wcNodejs"
            val file = new File(catalogDir, sample_file).toString()
     
            assetHelper.withCleaner(wsk.action, name) {
                (action, _) => action.create(name, Some(file), kind = Some("nodejs:6"))
            }
            wsk.action.get(name).stdout should include regex (""""kind": "nodejs:6"""")
 
            val run = wsk.action.invoke(name, Map("payload" -> "Five fuzzy felines".toJson))
            val expectedNumber = 3
            withActivation(wsk.activation, run) {
                activation =>
                    activation.getFieldPath("response", "success") should be(Some(true.toJson))
                    activation.getFieldPath("response", "result", "count").toString should be(
                        Some(expectedNumber).toString)
            }
    }
}
