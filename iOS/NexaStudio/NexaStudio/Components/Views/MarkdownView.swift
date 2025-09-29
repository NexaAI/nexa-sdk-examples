import SwiftUI
import MarkdownUI

struct MarkdownView: View {
    var content: String
    var scrollDisabled: Bool = true
    var fontSize: CGFloat = 16
    var fontColor: Color = Color.Text.primary
    var body: some View {
        ScrollView {
            Markdown(content)
        }
        .markdownTextStyle {
            MarkdownUI.ForegroundColor(fontColor)
            MarkdownUI.FontSize(fontSize)
        }
        .markdownTextStyle(\.strong) {
            MarkdownUI.FontSize(fontSize)
            MarkdownUI.ForegroundColor(fontColor)
        }
        .markdownBlockStyle(\.heading1){ configuration in
            configuration.label
                .markdownTextStyle {
                    FontFamily(.custom("FK Grotesk Neue Trial"))
                    FontWeight(.medium)
                }
        }
        .markdownBlockStyle(\.heading3) { configuration in
            configuration.label
                .markdownTextStyle {
                    FontFamily(.custom("FK Grotesk Neue Trial"))
                    FontWeight(.medium)
                    FontSize(20)
                }
        }
        .scrollDisabled(scrollDisabled)
    }
}

#Preview {
    ScrollView {
        MarkdownView(
            content:
                  """
                  <think>
                  Okay, the user wants me to compare the affordability of Cupertino and Evanston. Let me start by recalling the locations. Cupertino is in California, known for being a tech hub, and Evanston is in Illinois, a suburban area. 
                  
                  First, I should consider factors like housing costs. Cupertino is a high-cost area, so property values are high. Evanston is more affordable, maybe with lower property prices. That's one point. 
                  
                  Next, the cost of living. In Cupertino, there's a high cost of living, so people have to work more. In Evanston, the cost of living is lower, so people can afford to live there more easily. 
                  
                  Then, education. Evanston has schools that are more affordable compared to Cupertino, which has expensive schools. 
                  
                  Transportation is another thing. Evanston's transportation system is better, so people have more options. 
                  
                  Healthcare. Both areas have healthcare, but maybe Evanston is more affordable. 
                  
                  Real estate. As I said, Cupertino has higher property prices, so real estate can be more expensive. 
                  
                  I should also mention that these factors can vary based on the specific location, so it's good to check recent data to be accurate. 
                  
                  Wait, are there any other factors? Maybe income levels? If Evanston has a lower income, then the affordability could be better. But maybe the user is looking for a general comparison without considering income. 
                  
                  Also, need to make sure not to include any other details that might be misleading. Keep it clear and concise.
                  </think>
                  
                  Here's a comparison of the affordability of **Cupertino** and **Evanston** based on key factors:
                  
                  ### **1. Housing Costs**  
                  - **Cupertino**: High property values due to its status as a tech hub, making housing more expensive.  
                  - **Evanston**: More affordable housing with lower median property prices, making it easier to buy and live in.  
                  
                  ### **2. Cost of Living**  
                  - **Cupertino**: High cost of living, requiring more income for a similar lifestyle.  
                  - **Evanston**: Lower cost of living, allowing for a more budget-friendly approach to housing and daily expenses.  
                  
                  ### **3. Education**  
                  - **Cupertino**: Expensive schools with higher tuition and educational costs.  
                  - **Evanston**: More affordable public schools with better access to quality education.  
                  
                  ### **4. Transportation**  
                  - **Cupertino**: Well-developed public transportation (e.g., buses, trains) but may be less efficient compared to other cities.  
                  - **Evanston**: Improved public transit and biking infrastructure, making commuting easier.  
                  
                  ### **5. Healthcare**  
                  - **Cupertino**: Affordable healthcare options with strong public health systems.  
                  - **Evanston**: Affordable healthcare with good access to medical services.  
                  
                  ### **6. Real Estate**  
                  - **Cupertino**: High property prices (e.g., apartment costs), making real estate more expensive.  
                  - **Evanston**: Lower median home prices, ideal for affordability.  
                  
                  ### **Notes**  
                  Affordability can vary depending on location, income, and personal priorities. Both areas offer unique benefits, and factors like proximity to amenities, job markets, and local policies also play a role.
                  
                  Here's a comparison of the affordability of **Cupertino** and **Evanston** based on key factors:
                  
                  | **Factor**               | **Cupertino** | **Evanston** |
                  |--------------------------|-------------|-------------|
                  | **Housing Costs**         | High property values due to tech hub status, making housing more expensive.      | Affordable housing with lower median property prices.                        |
                  | **Cost of Living**        | High cost of living, requiring more income for a similar lifestyle.               | Lower cost of living, allowing for a budget-friendly approach to housing.     |
                  | **Education**            | Expensive schools with higher tuition and educational costs.                   | Affordable public schools with better access to quality education.         |
                  | **Transportation**        | Well-developed public transportation infrastructure.                          | Improved public transit and biking infrastructure.                       |
                  | **Healthcare**           | Affordable healthcare options with strong public health systems.                | Affordable healthcare with good access to medical services.                 |
                  | **Real Estate**          | High property prices, making real estate more expensive.                        | Lower median home prices, ideal for affordability.                        |
                  
                  **Summary**:  
                  - **Cupertino** offers a high cost of living and expensive housing, making it a destination for those seeking a premium lifestyle.  
                  - **Evanston** provides a more affordable environment with better access to essential services and lower property costs.  
                  
                  Both areas have unique advantages, and affordability depends on personal priorities and budget constraints.
                  """
        )
    }
}


#Preview {
    ScrollView {
        MarkdownView(
            content:
                  """
                  In 2000 words, **"The Whispering Willow"** captures the essence of resilience and hope that transcends generations. It tells a story not just about survival but also about how stories can heal wounds and inspire change in those who listen.
                  """
        )
    }
}
