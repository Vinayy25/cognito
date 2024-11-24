

gemini_system_prompt ="""

You are a highly advanced and helpful personal assistant, designed to assist the user with their questions and provide personalized, natural responses based on their previous conversation history.

Here are your key instructions:

1. **Personalized Assistance:** Utilize the provided conversation records to tailor your responses to the user's specific needs and preferences. Aim to be as helpful and relevant as possible, considering the context of the ongoing conversation.
   
2. **Record Utilization:** While you have access to a series of records from past conversations, you should use them to enhance the relevance and depth of your responses. Do not refer to the records explicitly, but use the information to inform your answers.

3. **Relevance of Records:** The records are ordered by relevance, with the most recent records at the top. Use these records to provide contextually appropriate responses, and feel free to draw from the most relevant ones if it improves your answer.

4. **Natural Conversation:** Maintain a conversational and friendly tone throughout your interactions. Ensure that your responses feel natural and engaging, as if you are having a real conversation with the user and always answer the users questions rather than cross-questioning.

5. **Handling Unrelated Records:** If the provided records are not relevant to the user's question, you may choose to ignore them and rely on your general knowledge to respond.

6. **Answer in less than 200 words**
**UNDERSTOOD**

Below are the records of previous conversations to assist you in crafting your responses. Use these to make your answers more personalized and relevant:

Records: 
"""







system_prompt_without_rag = """


You are a highly advanced and empathetic assistant, designed to provide the most accurate and helpful responses to the user's questions. Here are your key instructions:

1. **Empathetic Assistance:** Always respond in a warm, friendly, and understanding manner. Show empathy and understanding towards the user's needs and concerns.

2. **Best Knowledge:** Utilize your extensive knowledge base to provide the most accurate and helpful answers. Ensure that your responses are well-informed and reliable.

3. **Clarity and Conciseness:** Provide clear and concise answers. Avoid unnecessary jargon and ensure that your responses are easy to understand.

4. **Engaging Conversation:** Maintain a conversational tone that feels natural and engaging. Make the user feel heard and valued throughout the interaction.

5. **Avoid using symbols, emojis,'-', '!' and other non-standard characters**
6. **Answer in less than 200 words**



"""

smvitm_data = """

Shri Madhwa Vadiraja Institute of Technology & Management (SMVITM) is a private engineering college located in Bantakal, Udupi, Karnataka, India. Established in 2010 by the Shri Sode Vadiraja Mutt Education Trust, the institute is affiliated with Visvesvaraya Technological University (VTU) in Belagavi and is approved by the All India Council for Technical Education (AICTE). 

**Academic Programs:**

SMVITM offers undergraduate and postgraduate programs in various engineering disciplines:

- **Undergraduate Programs:**
  - Bachelor of Engineering (B.E.) in:
    - Civil Engineering
    - Computer Science and Engineering
    - Electronics and Communication Engineering
    - Mechanical Engineering
  - Bachelor of Science (Honors)

- **Postgraduate Programs:**
  - Master of Business Administration (MBA)
  - Doctoral Programs (Ph.D.) in:
    - Civil Engineering
    - Electronics and Communication Engineering
    - Mechanical Engineering
    - Mathematics
    - Physics
    - Chemistry

**Accreditation and Affiliations:**

- **Accreditation:** The institute has been accredited with an 'A' grade by the National Assessment and Accreditation Council (NAAC), achieving a CGPA of 3.13, the highest for any engineering college in Coastal Karnataka and the Mysuru region of VTU. 

- **Affiliations:** SMVITM is affiliated with Visvesvaraya Technological University (VTU) in Belagavi and is approved by the All India Council for Technical Education (AICTE).

**Campus and Facilities:**

- **Location:** The campus spans 70 acres in Vishwothama Nagar, Bantakal, approximately 12 km from Udupi town and 6 km from Katapady. 

- **Facilities:**
  - State-of-the-art laboratories and workshops
  - Central library with over 16,600 volumes and subscriptions to national and international journals
  - Separate hostels for boys and girls with modern amenities
  - Sports facilities including indoor and outdoor games, a multi-gym, and coaching for inter-collegiate competitions
  - Health center
  - Bank and transport services
  - Solar power unit and sewage treatment plant

**Student Activities and Achievements:**

- **Festivals and Events:** SMVITM organizes 'Varnothsava,' a state-level inter-collegiate techno-cultural fest, and an annual project exhibition and competition on Industrial Internet of Things (IIOT). 

- **Placements:** The institute has a strong placement record, with over 75% of students securing positions in reputed organizations such as TCS, Infosys, Wipro Technologies, Mindtree, Amazon, IBM, Bosch, and Volvo. 

- **Research:** SMVITM is engaged in research activities with university-approved research centers in all engineering and basic science departments, leading to publications in reputed journals. 

**Contact Information:**

- **Address:** Shri Madhwa Vadiraja Institute of Technology and Management, Vishwothama Nagar, Bantakal, Udupi – 574 115, Karnataka, India

- **Phone:** +91 9611615001, 0820-2589182, 183, 184

- **Email:** info@sode-edu.in

- **Website:** [https://sode-edu.in/](https://sode-edu.in/)

For more detailed information, you can visit the official website or contact the institute directly. 

Shri Madhwa Vadiraja Institute of Technology and Management (SMVITM), established in 2010, is a private, NAAC-accredited institution affiliated with Visvesvaraya Technological University (VTU). Located in Udupi, Karnataka, the college spans 70 acres and offers a range of undergraduate and postgraduate programs in engineering and management, including B.Tech in six disciplines and an MBA in Business Analytics.

### Academics and Infrastructure
- **Courses Offered**: Popular programs include Computer Science, Artificial Intelligence, Data Science, and Electronics & Communication Engineering. Admissions are primarily through KCET, COMEDK UGET, or institute-specific management quotas.
- **Facilities**: The campus has a central library with over 28,000 resources, Wi-Fi-enabled classrooms, research labs, and hostel accommodations. It is equipped with ICT-enabled classrooms and research facilities.
- **IT and Sustainability**: With over 500 computers and renewable energy initiatives like 125 kW solar panels, the institute emphasizes sustainability and technological access.

### Student Development and Extracurriculars
- **Student Support**: The institute offers scholarships to over 70% of students and has a strong focus on co-curricular and extracurricular activities. Clubs, sports, and cultural events are actively promoted.
- **Placements**: While placement statistics vary, the college strives to connect students with industries and supports internships in diverse sectors.

### Vision and Governance
- **Mission**: Inspired by holistic education principles, the institution prioritizes academic excellence and personal growth under the leadership of H.H. Shri Vishwavallabha Theertha Swamiji.
- **Governance**: SMVITM uses a participative governance model with a governing council and quality assurance mechanisms. Faculty members are encouraged to engage in professional development through conferences and workshops.

For more details, you can explore their [official website](https://sode-edu.in) or resources like [Careers360](https://www.careers360.com) and [CollegeDunia](https://collegedunia.com).
"""